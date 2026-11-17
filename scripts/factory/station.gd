class_name Station
extends Control
## One factory or the market. Base production is manual; four options change it.

signal buy_requested(station: Station)
signal produce_requested(station: Station)
signal trait_requested(station: Station, kind: String)
signal produced(item: String)

const DENY_TIME: float = 0.25
const OPTION_H: float = 36.0
const AUTO_H: float = 32.0
const TAP_DISTANCE: float = 14.0
const FONT: Font = preload("res://assets/fonts/Vazirmatn.ttf")

var data: StationData
var board: GameBoard
var locked: bool = false
var input_count: int = 0
var output_count: int = 0
var working: bool = false
var affordable: bool = false
var trait_affordable: Dictionary = {}

var speed_level: int = 0
var price_level: int = 0
var space_level: int = 0
var auto_trait: bool = false

var _progress: float = 0.0
var _deny: float = 0.0
var _punch_tween: Tween
var _style: StyleBoxFlat = StyleBoxFlat.new()
var _inner_style: StyleBoxFlat = StyleBoxFlat.new()
var _option_style: StyleBoxFlat = StyleBoxFlat.new()
var _bar_style: StyleBoxFlat = StyleBoxFlat.new()
var _press_pos: Vector2 = Vector2.ZERO
var _pressed: bool = false
var _press_zone: String = "main"
var _press_option: int = 0
var _art: Texture2D
var _hovered: bool = false
var _anim: float = 0.0
var _hover_tween: Tween


func setup(station_data: StationData, is_locked: bool, board_ref: GameBoard, start_traits: Dictionary = {}) -> void:
	data = station_data
	locked = is_locked
	board = board_ref
	speed_level = clampi(int(start_traits.get("speed", 0)), 0, 5)
	price_level = clampi(int(start_traits.get("price", 0)), 0, 5)
	space_level = clampi(int(start_traits.get("space", 0)), 0, 5)
	auto_trait = int(start_traits.get("auto", 0)) > 0
	_style.set_corner_radius_all(20)
	_style.set_border_width_all(2)
	_style.shadow_color = Palette.SHADOW
	_style.shadow_size = 10
	_style.shadow_offset = Vector2(0, 5)
	_inner_style.set_corner_radius_all(16)
	_inner_style.set_border_width_all(0)
	_option_style.set_corner_radius_all(9)
	_option_style.set_border_width_all(1)
	_bar_style.set_corner_radius_all(3)
	_art = Art.factory(data.id)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))
	queue_redraw()


func _process(delta: float) -> void:
	_anim += delta
	if working or _hovered or (data != null and data.is_market):
		queue_redraw()


func _on_hover(on: bool) -> void:
	_hovered = on
	if _hover_tween != null:
		_hover_tween.kill()
	pivot_offset = size * 0.5
	_hover_tween = create_tween()
	_hover_tween.tween_property(self, "scale", Vector2(1.012, 1.012) if on else Vector2.ONE, 0.12)
	queue_redraw()


func power_points() -> int:
	return speed_level + price_level + space_level + (1 if auto_trait else 0)


func _accent_color() -> Color:
	if data == null:
		return Palette.MUTED
	match data.id:
		"mine":
			return Palette.WARN
		"smelter":
			return Color("#ff8a2a")
		"mill":
			return Palette.STEEL
		"tool_shop":
			return Palette.CYAN
		"car_plant":
			return Color("#35c6ff")
		"appliance_plant":
			return Color("#2ee6c5")
		"market":
			return Palette.WARN
	return data.color


func set_unlocked() -> void:
	locked = false
	_deny = 0.0
	queue_redraw()


func has_trait(key: String) -> bool:
	return trait_level(key) > 0


func trait_level(key: String) -> int:
	match key:
		"speed":
			return speed_level
		"price":
			return price_level
		"space":
			return space_level
		"auto":
			return 1 if auto_trait else 0
	return 0


func trait_max_level(key: String) -> int:
	return 1 if key == "auto" else 5


func is_trait_max(key: String) -> bool:
	return trait_level(key) >= trait_max_level(key)


func apply_trait(key: String) -> void:
	match key:
		"speed":
			speed_level = mini(speed_level + 1, 5)
		"price":
			price_level = mini(price_level + 1, 5)
		"space":
			space_level = mini(space_level + 1, 5)
		"auto":
			auto_trait = true
	queue_redraw()


func trait_cost(key: String) -> int:
	if data == null or data.is_market or locked or is_trait_max(key):
		return -1
	var base: int = data.trait_cost
	if key == "auto":
		return maxi(base * 2, 1)
	var level: int = trait_level(key)
	return maxi(roundi(base * pow(1.5, level)), 1)


func is_auto() -> bool:
	return data != null and not data.is_market and auto_trait


func buffer_cap() -> int:
	return ceili(float(data.buffer_cap() + 2 * space_level) * SaveManager.global_capacity())


func cycle_time() -> float:
	return data.cycle_time() / ((1.0 + 0.5 * float(speed_level)) * SaveManager.global_speed())


func sell_multiplier() -> float:
	return 1.0 + 0.5 * float(price_level)


func manual_produce() -> bool:
	if locked or data == null or data.is_market or is_auto() or working:
		return false
	if output_count >= buffer_cap():
		return false
	if input_count < data.input_amount:
		return false
	input_count -= data.input_amount
	working = true
	_progress = 0.0
	queue_redraw()
	return true


func step(delta: float) -> void:
	if locked or data == null or data.is_market:
		return
	_deny = maxf(_deny - delta, 0.0)
	var cap: int = buffer_cap()
	if working:
		_progress += delta
		if _progress >= cycle_time():
			_progress = 0.0
			working = false
			output_count += 1
			produced.emit(data.output_item)
	if is_auto() and not working and input_count >= data.input_amount and output_count < cap:
		input_count -= data.input_amount
		working = true
		_progress = 0.0
	queue_redraw()


func receive_item(item: String) -> bool:
	if locked or data == null or data.is_market:
		return false
	if data.input_item != item:
		return false
	if input_count >= buffer_cap():
		return false
	input_count += 1
	queue_redraw()
	return true


func can_accept_item(item: String) -> bool:
	if locked or data == null:
		return false
	if data.is_market:
		return Economy.is_sellable(item)
	return data.input_item == item and input_count < buffer_cap()


func is_blocked() -> bool:
	return not locked and data != null and not data.is_market and not working and output_count >= buffer_cap()


func center() -> Vector2:
	return position + size * 0.5


func deny() -> void:
	_deny = DENY_TIME
	queue_redraw()


func punch() -> void:
	pivot_offset = size * 0.5
	if _punch_tween != null:
		_punch_tween.kill()
	scale = Vector2(1.08, 1.08)
	_punch_tween = create_tween()
	_punch_tween.tween_property(self, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _gui_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb != null and mb.button_index == MOUSE_BUTTON_LEFT:
		if mb.pressed:
			_press_pos = mb.position
			_pressed = true
			_set_press_zone(mb.position)
			return
		if _pressed:
			_pressed = false
			if mb.position.distance_to(_press_pos) <= TAP_DISTANCE:
				_tap(_press_zone, _press_option)
				accept_event()
			return
	var motion := event as InputEventMouseMotion
	if motion != null and _pressed and motion.position.distance_to(_press_pos) > TAP_DISTANCE:
		_pressed = false


func _set_press_zone(pos: Vector2) -> void:
	_press_option = 0
	if locked or data == null or data.is_market:
		_press_zone = "main"
		return
	if pos.y >= size.y - AUTO_H:
		_press_zone = "auto"
	elif pos.y >= size.y - AUTO_H - OPTION_H:
		_press_zone = "option"
		var seg: float = (size.x - 16.0) / 3.0
		_press_option = clampi(int((pos.x - 8.0) / maxf(seg, 1.0)), 0, 2)
	else:
		_press_zone = "main"


func _tap(zone: String, option: int) -> void:
	if locked:
		buy_requested.emit(self)
		return
	if data == null or data.is_market:
		return
	if zone == "option":
		var keys: Array[String] = ["speed", "price", "space"]
		trait_requested.emit(self, keys[clampi(option, 0, 2)])
		return
	if zone == "auto":
		trait_requested.emit(self, "auto")
		return
	if is_auto():
		return
	produce_requested.emit(self)


func _get_drag_data(_at_position: Vector2) -> Variant:
	if locked or data == null or data.is_market or data.output_item == "":
		return null
	if board == null or not board.can_start_drag(self):
		return null
	return {"source": self}


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false
	var source: Station = data.get("source") as Station
	return board != null and board.can_connect(source, self)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if typeof(data) != TYPE_DICTIONARY:
		return
	var source: Station = data.get("source") as Station
	if board != null:
		board.connect_stations(source, self)


func _draw() -> void:
	if data == null:
		return
	var accent: Color = _accent_color()
	_draw_card_base(accent)
	_draw_art(accent)
	if not locked and not data.is_market:
		_draw_power_badge(accent)
	var font: Font = FONT
	draw_string(font, Vector2(0, 84), I18n.station_name(data.id), HORIZONTAL_ALIGNMENT_CENTER, size.x, 20, Palette.TEXT)
	if locked:
		_draw_locked(accent, font)
		return
	if data.is_market:
		_draw_market(accent, font)
		return
	_draw_factory(accent, font)


func _draw_card_base(accent: Color) -> void:
	_style.bg_color = Palette.LOCKED if locked else Palette.PANEL
	_style.border_color = _border_color(accent)
	_style.shadow_size = 16 if _hovered else 9
	_style.shadow_color = Color(accent.r, accent.g, accent.b, 0.2) if (_hovered or working) else Palette.SHADOW
	draw_style_box(_style, Rect2(Vector2.ZERO, size))
	_inner_style.bg_color = Color(accent.r, accent.g, accent.b, 0.055)
	draw_style_box(_inner_style, Rect2(6, 6, size.x - 12, 72))
	draw_line(Vector2(22, 5), Vector2(size.x - 22, 5), Color(accent.r, accent.g, accent.b, 0.8), 2.0)
	if _hovered:
		draw_rect(Rect2(2, 2, size.x - 4, size.y - 4), Color(accent.r, accent.g, accent.b, 0.3), false, 1.5)


func _draw_art(accent: Color) -> void:
	var center := Vector2(size.x * 0.5, 38.0)
	var pulse: float = 0.5 + 0.5 * sin(_anim * 4.0)
	var glow_alpha: float = 0.1 + (0.07 * pulse if working or (data != null and data.is_market) else 0.0)
	draw_circle(center, 36.0, Color(accent.r, accent.g, accent.b, glow_alpha))
	draw_circle(Vector2(center.x, 68.0), 25.0, Color(0.0, 0.0, 0.0, 0.18))
	if _art != null:
		var tint := Color(1, 1, 1, 0.35) if locked else Color(1, 1, 1, 1)
		draw_texture_rect(_art, Rect2(center.x - 30.0, 8.0, 60.0, 60.0), false, tint)


func _draw_power_badge(accent: Color) -> void:
	var rect := Rect2(size.x - 96.0, 10.0, 86.0, 22.0)
	_draw_pill(rect, Color(accent.r, accent.g, accent.b, 0.18), accent)
	draw_string(FONT, Vector2(rect.position.x, rect.position.y + 15.0), "%s %d" % [I18n.t("power"), power_points()], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 10, accent.lightened(0.25))


func _draw_pill(rect: Rect2, fill: Color, border: Color) -> void:
	_option_style.bg_color = fill
	_option_style.border_color = border
	draw_style_box(_option_style, rect)


func _draw_locked(accent: Color, font: Font) -> void:
	draw_string(font, Vector2(0, 110), I18n.t("locked"), HORIZONTAL_ALIGNMENT_CENTER, size.x, 15, Palette.MUTED)
	var rect := Rect2(34, 146, size.x - 68, 50)
	_option_style.bg_color = Color(accent.r, accent.g, accent.b, 0.18) if affordable else Palette.PANEL_LIGHT
	_option_style.border_color = accent if affordable else Palette.PANEL_HIGH
	draw_style_box(_option_style, rect)
	var color: Color = Palette.GOOD if affordable else Palette.MUTED
	draw_string(font, Vector2(rect.position.x, rect.position.y + 32), I18n.t("tap_buy") % data.buy_cost, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 15, color)


func _draw_market(accent: Color, font: Font) -> void:
	draw_string(font, Vector2(0, 104), I18n.t("open").to_upper() if not I18n.is_fa() else I18n.t("open"), HORIZONTAL_ALIGNMENT_CENTER, size.x, 14, Palette.GOOD)
	for i in Economy.ORDER.size():
		var product: String = Economy.ORDER[i]
		var x: float = 18.0 + float(i) * 50.0
		var icon: Texture2D = Art.product(product)
		if icon != null:
			draw_texture_rect(icon, Rect2(x, 118, 24, 24), false)
		draw_string(font, Vector2(x - 5.0, 156), "$%d" % Economy.sell_price(product), HORIZONTAL_ALIGNMENT_CENTER, 34, 10, Palette.MUTED)
	draw_string(font, Vector2(0, 188), I18n.t("drag_here"), HORIZONTAL_ALIGNMENT_CENTER, size.x, 13, Palette.MUTED)


func _draw_factory(accent: Color, font: Font) -> void:
	var status: String
	var status_color: Color
	var cap: int = buffer_cap()
	if is_auto():
		status = I18n.t("auto")
		status_color = Palette.GOOD
	elif working:
		status = I18n.t("working")
		status_color = accent
	elif output_count >= cap:
		status = I18n.t("output_full")
		status_color = Palette.BAD
	elif input_count < data.input_amount:
		status = I18n.t("need") % I18n.product_name(data.input_item)
		status_color = Palette.WARN
	else:
		status = I18n.t("tap_produce")
		status_color = Palette.WARN
	draw_string(font, Vector2(0, 102), status, HORIZONTAL_ALIGNMENT_CENTER, size.x, 13, status_color)
	if data.input_amount > 0:
		var input_icon: Texture2D = Art.product(data.input_item)
		if input_icon != null:
			draw_texture_rect(input_icon, Rect2(18, 104, 16, 16), false)
		var input_text: String = "%s %d/%d" % [I18n.product_name(data.input_item), input_count, cap]
		draw_string(font, Vector2(40, 117), input_text, HORIZONTAL_ALIGNMENT_LEFT, size.x - 58, 12, Palette.MUTED)
	var output_icon: Texture2D = Art.product(data.output_item)
	if output_icon != null:
		draw_texture_rect(output_icon, Rect2(18, 122, 16, 16), false)
	draw_string(font, Vector2(40, 135), "%s %d/%d" % [I18n.t("out_label"), output_count, cap], HORIZONTAL_ALIGNMENT_LEFT, size.x - 58, 12, Palette.MUTED)
	_draw_progress_bar(accent)
	_draw_options(font)



func _draw_progress_bar(accent: Color) -> void:
	var rect := Rect2(18, size.y - 75, size.x - 36, 6)
	_bar_style.bg_color = Palette.BG_DEEP
	draw_style_box(_bar_style, rect)
	if working:
		var ratio: float = clampf(_progress / cycle_time(), 0.0, 1.0)
		_bar_style.bg_color = accent
		draw_style_box(_bar_style, Rect2(rect.position, Vector2(maxf(rect.size.x * ratio, 6.0), rect.size.y)))
		var glow_alpha: float = 0.18 + 0.12 * (0.5 + 0.5 * sin(_anim * 4.0))
		draw_line(Vector2(rect.position.x, rect.position.y - 2.0), Vector2(rect.position.x + rect.size.x * ratio, rect.position.y - 2.0), Color(accent.r, accent.g, accent.b, glow_alpha), 2.0)


func _draw_options(font: Font) -> void:
	var keys: Array[String] = ["speed", "price", "space"]
	var margin: float = 8.0
	var gap: float = 4.0
	var total: float = size.x - margin * 2.0
	var seg: float = (total - gap * 2.0) / 3.0
	var top: float = size.y - AUTO_H - OPTION_H
	for i in 3:
		var key: String = keys[i]
		var level: int = trait_level(key)
		var maxed: bool = is_trait_max(key)
		var x: float = margin + i * (seg + gap)
		var affordable_key: bool = bool(trait_affordable.get(key, false))
		_option_style.bg_color = Palette.GOOD.darkened(0.58) if level > 0 else Palette.PANEL_LIGHT
		_option_style.border_color = Palette.GOOD if (level > 0 or affordable_key) else Palette.PANEL_HIGH
		draw_style_box(_option_style, Rect2(x, top + 2, seg, OPTION_H - 4))
		var effect: String = _option_effect(key, level if key == "speed" else maxi(level, 1))
		draw_string(font, Vector2(x + 2, top + 15), effect, HORIZONTAL_ALIGNMENT_CENTER, seg - 4, 12, Palette.TEXT if level > 0 else Palette.MUTED)
		var line: String
		var line_color: Color
		if maxed:
			line = "Lv %d/%d MAX" % [level, 5]
			line_color = Palette.TEXT
		else:
			var cost: int = trait_cost(key)
			line = "Lv %d/%d  $%d" % [level, 5, cost]
			line_color = Palette.GOOD if affordable_key else Palette.MUTED
		draw_string(font, Vector2(x + 2, top + 30), line, HORIZONTAL_ALIGNMENT_CENTER, seg - 4, 11, line_color)
	var auto_top: float = size.y - AUTO_H
	var auto_affordable: bool = bool(trait_affordable.get("auto", false))
	_option_style.bg_color = Palette.GOOD.darkened(0.58) if auto_trait else Palette.PANEL_LIGHT
	_option_style.border_color = Palette.GOOD if (auto_trait or auto_affordable) else Palette.PANEL_HIGH
	draw_style_box(_option_style, Rect2(margin, auto_top + 2, size.x - margin * 2.0, AUTO_H - 4))
	var auto_text: String = I18n.t("auto")
	var auto_color: Color = Palette.MUTED
	if auto_trait:
		auto_text += " ✓"
		auto_color = Palette.TEXT
	else:
		auto_text += " $%d" % trait_cost("auto")
		if auto_affordable:
			auto_color = Palette.GOOD
	draw_string(font, Vector2(margin, auto_top + 21), auto_text, HORIZONTAL_ALIGNMENT_CENTER, size.x - margin * 2.0, 13, auto_color)


func _option_effect(key: String, level: int) -> String:
	match key:
		"speed":
			return "%.1f/s" % ((1.0 + 0.5 * float(level)) * SaveManager.global_speed())
		"price":
			return "+%d%%" % int(50 * level)
		"space":
			return "+%d" % int(2 * level)
	return ""


func _border_color(accent: Color) -> Color:
	var pulse: float = 0.5 + 0.5 * sin(_anim * 4.0)
	if _deny > 0.0:
		return Palette.BAD
	if locked:
		return Palette.BELT
	if is_blocked():
		return Palette.BAD
	if data.is_market:
		return accent.lightened(0.08 + 0.12 * pulse)
	if working:
		return accent.lightened(0.08 + 0.12 * pulse)
	if _hovered:
		return accent.lightened(0.18)
	return accent.darkened(0.12)
