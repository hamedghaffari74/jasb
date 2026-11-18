class_name Hud
extends Control
## Top command bar + economy dashboard. All values come from the real game state.

signal pause_pressed
signal global_pressed

const FONT: Font = preload("res://assets/fonts/Vazirmatn.ttf")

var _money: int = 0
var _tip_label: Label
var _cash_pop: float = 0.0
var _tip_hold: float = 0.0
var _star_label: Label
var _star_panel: Panel
var _star_glow: StyleBoxFlat = StyleBoxFlat.new()
var _prestige_ready: bool = false
var _time: float = 0.0

var _panel_style: StyleBoxFlat = StyleBoxFlat.new()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(720, 1280)
	set_process(true)
	_panel_style.bg_color = Color(Palette.PANEL.r, Palette.PANEL.g, Palette.PANEL.b, 0.97)
	_panel_style.set_corner_radius_all(0)
	_panel_style.corner_radius_bottom_left = 18
	_panel_style.corner_radius_bottom_right = 18
	_panel_style.set_border_width_all(0)
	_panel_style.shadow_color = Palette.SHADOW
	_panel_style.shadow_size = 14
	_panel_style.shadow_offset = Vector2(0, 5)
	_star_glow.bg_color = Color(0, 0, 0, 0)
	_star_glow.set_corner_radius_all(20)
	_star_glow.set_border_width_all(2)
	_star_glow.border_color = Palette.CYAN
	_star_glow.shadow_color = Palette.CYAN
	_star_glow.shadow_size = 10
	_build_pause_button()
	_build_global_button()
	_build_tip()


func _process(delta: float) -> void:
	_time += delta
	if _tip_hold > 0.0:
		_tip_hold = maxf(_tip_hold - delta, 0.0)
	if _star_label != null:
		var stars_text: String = str(SaveManager.blue_stars)
		if _star_label.text != stars_text:
			_star_label.text = stars_text
	var ready: bool = SaveManager.can_prestige()
	if ready != _prestige_ready:
		_prestige_ready = ready
		queue_redraw()
	elif ready:
		queue_redraw()
	if _cash_pop > 0.0:
		_cash_pop = maxf(_cash_pop - delta * 3.8, 0.0)
		queue_redraw()


func set_money(value: int) -> void:
	if _money == value:
		return
	_money = value
	queue_redraw()


func set_tip(text: String) -> void:
	if _tip_hold > 0.0:
		return
	if _tip_label != null and _tip_label.text != text:
		_tip_label.text = text


func flash_tip(text: String, seconds: float = 4.0) -> void:
	_tip_hold = seconds
	if _tip_label != null:
		_tip_label.text = text


func pop_cash() -> void:
	_cash_pop = 1.0


func _build_pause_button() -> void:
	var button := Button.new()
	button.text = "II"
	button.position = Vector2(640, 20)
	button.size = Vector2(54, 54)
	button.custom_minimum_size = Vector2(54, 54)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Palette.WARN)
	button.add_theme_color_override("font_hover_color", Palette.TEXT)
	button.add_theme_color_override("font_pressed_color", Palette.TEXT)
	button.add_theme_stylebox_override("normal", _round_button(Palette.PANEL, Palette.WARN))
	button.add_theme_stylebox_override("hover", _round_button(Palette.PANEL_HIGH, Palette.WARN))
	button.add_theme_stylebox_override("pressed", _round_button(Palette.PANEL_LIGHT, Palette.WARN))
	button.add_theme_stylebox_override("focus", _round_button(Palette.PANEL_HIGH, Palette.TEXT))
	button.pressed.connect(func() -> void: pause_pressed.emit())
	add_child(button)


func _build_global_button() -> void:
	_star_panel = Panel.new()
	_star_panel.position = Vector2(578, 20)
	_star_panel.size = Vector2(54, 54)
	_star_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style: StyleBoxFlat = _star_style()
	_star_panel.add_theme_stylebox_override("panel", style)
	add_child(_star_panel)
	var icon := TextureRect.new()
	icon.texture = Art.ui("star")
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.position = Vector2(13, 4)
	icon.size = Vector2(28, 28)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_star_panel.add_child(icon)
	_star_label = UiKit.label(str(SaveManager.blue_stars), 12, Palette.CYAN)
	_star_label.position = Vector2(0, 30)
	_star_label.size = Vector2(54, 18)
	_star_label.text_direction = Control.TEXT_DIRECTION_LTR
	_star_panel.add_child(_star_label)
	var hit := Button.new()
	hit.position = Vector2.ZERO
	hit.size = Vector2(54, 54)
	hit.custom_minimum_size = Vector2(54, 54)
	hit.focus_mode = Control.FOCUS_NONE
	hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hit.tooltip_text = I18n.t("global_title")
	var empty := StyleBoxEmpty.new()
	hit.add_theme_stylebox_override("normal", empty)
	hit.add_theme_stylebox_override("hover", empty)
	hit.add_theme_stylebox_override("pressed", empty)
	hit.add_theme_stylebox_override("focus", empty)
	hit.pressed.connect(func() -> void: global_pressed.emit())
	_star_panel.add_child(hit)


func _star_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(Palette.PANEL_LIGHT.r, Palette.PANEL_LIGHT.g, Palette.PANEL_LIGHT.b, 0.92)
	style.set_corner_radius_all(14)
	style.set_border_width_all(2)
	style.border_color = Color(Palette.CYAN.r, Palette.CYAN.g, Palette.CYAN.b, 0.75)
	style.shadow_color = Color(Palette.CYAN.r, Palette.CYAN.g, Palette.CYAN.b, 0.22)
	style.shadow_size = 7
	style.shadow_offset = Vector2(0, 2)
	return style


func _round_button(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.set_corner_radius_all(16)
	style.set_border_width_all(2)
	style.border_color = border
	style.shadow_color = Palette.SHADOW
	style.shadow_size = 6
	style.shadow_offset = Vector2(0, 3)
	return style


func _build_tip() -> void:
	_tip_label = Label.new()
	_tip_label.position = Vector2(24, 1190)
	_tip_label.size = Vector2(672, 40)
	_tip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tip_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tip_label.text_direction = Control.TEXT_DIRECTION_RTL if I18n.is_fa() else Control.TEXT_DIRECTION_AUTO
	_tip_label.add_theme_font_size_override("font_size", 12)
	_tip_label.add_theme_color_override("font_color", Palette.WARN)
	_tip_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_tip_label.add_theme_constant_override("shadow_offset_x", 0)
	_tip_label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(_tip_label)


func _draw() -> void:
	_draw_top_bar()
	_draw_star_glow()


func _draw_star_glow() -> void:
	if not _prestige_ready:
		return
	var pulse: float = 0.5 + 0.5 * sin(_time * 4.0)
	_star_glow.border_color = Color(Palette.CYAN.r, Palette.CYAN.g, Palette.CYAN.b, 0.3 + 0.4 * pulse)
	_star_glow.shadow_color = Color(Palette.CYAN.r, Palette.CYAN.g, Palette.CYAN.b, 0.2 + 0.3 * pulse)
	draw_style_box(_star_glow, Rect2(570, 12, 70, 70))


func _draw_top_bar() -> void:
	draw_style_box(_panel_style, Rect2(0, 0, 720, 96))
	draw_line(Vector2(0, 95), Vector2(720, 95), Color(Palette.WARN.r, Palette.WARN.g, Palette.WARN.b, 0.35), 2.0)
	draw_string(FONT, Vector2(24, 38), "IRON CHAIN", HORIZONTAL_ALIGNMENT_LEFT, 300, 25, Palette.WARN)
	draw_string(FONT, Vector2(24, 62), I18n.t("subtitle"), HORIZONTAL_ALIGNMENT_LEFT, 300, 11, Palette.MUTED)
	var coin_center := Vector2(406, 54)
	draw_circle(coin_center, 13.0, Palette.GOLD)
	draw_circle(coin_center, 10.0, Color("#e0a000"))
	draw_string(FONT, Vector2(400, 59), "$", HORIZONTAL_ALIGNMENT_CENTER, 12, 13, Color("#493000"))
	var cash_size: int = 28 + int(_cash_pop * 6.0)
	var cash_color: Color = Palette.GOOD.lightened(0.12 * _cash_pop)
	var cash_text: String = "$%d" % _money
	var cash_width: float = 136.0
	var measured: float = FONT.get_string_size(cash_text, HORIZONTAL_ALIGNMENT_LEFT, -1, cash_size).x
	if measured > cash_width:
		cash_size = maxi(15, int(float(cash_size) * cash_width / measured))
	draw_string(FONT, Vector2(426, 65), cash_text, HORIZONTAL_ALIGNMENT_LEFT, int(cash_width), cash_size, cash_color)
	draw_string(FONT, Vector2(426, 38), I18n.t("cash"), HORIZONTAL_ALIGNMENT_LEFT, int(cash_width), 9, Palette.MUTED)
