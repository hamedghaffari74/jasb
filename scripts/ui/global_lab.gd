class_name GlobalLab
extends Control
## Full-screen permanent-upgrade lab: blue stars, ascension and three global tracks.

signal closed
signal prestiged

var _panel: Panel
var _star_icon: TextureRect
var _stars_label: Label
var _ascensions_label: Label
var _prestige_bar: ProgressBar
var _prestige_progress: Label
var _prestige_hint: Label
var _prestige_reward: Label
var _prestige_button: Button
var _cards: Dictionary = {}
var _confirm_until: int = 0
var _time: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	UiKit.add_dim(self)
	_panel = Panel.new()
	_panel.position = Vector2(16, 24)
	_panel.size = Vector2(688, 1232)
	_panel.add_theme_stylebox_override("panel", _panel_style())
	add_child(_panel)
	var backdrop := LabBackdrop.new()
	backdrop.position = Vector2.ZERO
	backdrop.size = _panel.size
	_panel.add_child(backdrop)
	var line := ColorRect.new()
	line.color = Color(Palette.CYAN.r, Palette.CYAN.g, Palette.CYAN.b, 0.55)
	line.position = Vector2(28, 2)
	line.size = Vector2(632, 3)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(line)
	_build_header()
	_build_prestige()
	for i in GlobalUpgrades.TRACKS.size():
		_build_upgrade(GlobalUpgrades.TRACKS[i], 368.0 + float(i) * 220.0)
	_build_help()
	_refresh_all()
	AudioManager.play("click")


func _process(delta: float) -> void:
	_time += delta
	if _star_icon != null:
		_star_icon.scale = Vector2.ONE * (1.0 + 0.025 * sin(_time * 3.2))
	if _confirm_until > 0 and Time.get_ticks_msec() > _confirm_until:
		_confirm_until = 0
		_refresh_prestige()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		_close()


func _build_header() -> void:
	_star_icon = TextureRect.new()
	_star_icon.texture = Art.ui("star")
	_star_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_star_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_star_icon.position = Vector2(24, 14)
	_star_icon.size = Vector2(46, 46)
	_star_icon.pivot_offset = Vector2(23, 23)
	_star_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_star_icon)
	var title: Label = _label(I18n.t("global_title"), 27, Palette.CYAN, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(20, 10)
	title.size = Vector2(648, 38)
	_panel.add_child(title)
	var subtitle: Label = _label(I18n.t("global_subtitle"), 13, Palette.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	subtitle.position = Vector2(20, 48)
	subtitle.size = Vector2(648, 20)
	_panel.add_child(subtitle)
	var chip := Panel.new()
	chip.position = Vector2(250, 76)
	chip.size = Vector2(188, 40)
	chip.add_theme_stylebox_override("panel", _chip_style())
	_panel.add_child(chip)
	var chip_icon := TextureRect.new()
	chip_icon.texture = Art.ui("star")
	chip_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	chip_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	chip_icon.position = Vector2(18, 7)
	chip_icon.size = Vector2(26, 26)
	chip_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(chip_icon)
	_stars_label = _label("0", 20, Palette.CYAN, HORIZONTAL_ALIGNMENT_LEFT)
	_stars_label.position = Vector2(54, -2)
	_stars_label.size = Vector2(116, 44)
	_stars_label.text_direction = Control.TEXT_DIRECTION_LTR
	chip.add_child(_stars_label)
	var stars_caption: Label = _label(I18n.t("global_stars"), 11, Palette.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	stars_caption.position = Vector2(250, 118)
	stars_caption.size = Vector2(188, 18)
	_panel.add_child(stars_caption)
	_ascensions_label = _label("", 11, Palette.MUTED, HORIZONTAL_ALIGNMENT_RIGHT)
	_ascensions_label.position = Vector2(470, 118)
	_ascensions_label.size = Vector2(130, 18)
	_panel.add_child(_ascensions_label)
	var close_button: Button = UiKit.button("X", Palette.PANEL_LIGHT)
	close_button.custom_minimum_size = Vector2(44, 44)
	close_button.position = Vector2(618, 16)
	close_button.size = Vector2(44, 44)
	close_button.add_theme_font_size_override("font_size", 17)
	close_button.pressed.connect(_close)
	_panel.add_child(close_button)


func _build_prestige() -> void:
	var card := Panel.new()
	card.position = Vector2(20, 142)
	card.size = Vector2(648, 206)
	card.add_theme_stylebox_override("panel", _prestige_style())
	_panel.add_child(card)
	var line := ColorRect.new()
	line.color = Color(Palette.GOLD.r, Palette.GOLD.g, Palette.GOLD.b, 0.7)
	line.position = Vector2(18, 0)
	line.size = Vector2(612, 3)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(line)
	var title: Label = _label(I18n.t("ascension"), 21, Palette.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	title.position = Vector2(16, 10)
	title.size = Vector2(616, 28)
	card.add_child(title)
	_prestige_progress = _label("", 13, Palette.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	_prestige_progress.position = Vector2(16, 40)
	_prestige_progress.size = Vector2(616, 20)
	card.add_child(_prestige_progress)
	_prestige_bar = ProgressBar.new()
	_prestige_bar.position = Vector2(20, 64)
	_prestige_bar.size = Vector2(608, 14)
	_prestige_bar.min_value = 0.0
	_prestige_bar.max_value = 100.0
	_prestige_bar.show_percentage = false
	_prestige_bar.add_theme_stylebox_override("background", _bar_bg())
	_prestige_bar.add_theme_stylebox_override("fill", _bar_fill())
	card.add_child(_prestige_bar)
	_prestige_hint = _label("", 13, Palette.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	_prestige_hint.position = Vector2(16, 84)
	_prestige_hint.size = Vector2(616, 20)
	card.add_child(_prestige_hint)
	_prestige_reward = _label("", 13, Palette.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	_prestige_reward.position = Vector2(16, 106)
	_prestige_reward.size = Vector2(616, 18)
	card.add_child(_prestige_reward)
	_prestige_button = UiKit.button(I18n.t("ascension_reset"), Palette.CYAN.darkened(0.35))
	_prestige_button.custom_minimum_size = Vector2(608, 52)
	_prestige_button.position = Vector2(20, 132)
	_prestige_button.size = Vector2(608, 52)
	_prestige_button.add_theme_font_size_override("font_size", 17)
	_prestige_button.pressed.connect(_on_prestige_pressed)
	card.add_child(_prestige_button)


func _build_upgrade(track: String, y: float) -> void:
	var accent: Color = _track_color(track)
	var card := Panel.new()
	card.position = Vector2(20, y)
	card.size = Vector2(648, 196)
	card.add_theme_stylebox_override("panel", _card_style(accent, false))
	_panel.add_child(card)
	var line := ColorRect.new()
	line.color = Color(accent.r, accent.g, accent.b, 0.7)
	line.position = Vector2(18, 0)
	line.size = Vector2(612, 3)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(line)
	var margin := MarginContainer.new()
	margin.position = Vector2.ZERO
	margin.size = card.size
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	card.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	margin.add_child(row)
	var icon_box := Panel.new()
	icon_box.custom_minimum_size = Vector2(72, 72)
	icon_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon_box.add_theme_stylebox_override("panel", _icon_style(accent))
	row.add_child(icon_box)
	var icon := TextureRect.new()
	icon.texture = Art.ui("global_" + track)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.position = Vector2(9, 9)
	icon.size = Vector2(54, 54)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_box.add_child(icon)
	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text_box.add_theme_constant_override("separation", 4)
	row.add_child(text_box)
	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	text_box.add_child(title_row)
	var name_label: Label = _label(I18n.t("global_" + track), 19, accent, _align())
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(name_label)
	var current_label: Label = _label("", 15, accent, _align())
	title_row.add_child(current_label)
	var desc_label: Label = _label(I18n.t("global_" + track + "_desc"), 13, Palette.MUTED, _align())
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size = Vector2(0, 34)
	desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_child(desc_label)
	var pip_row := HBoxContainer.new()
	text_box.add_child(pip_row)
	var pips := LevelPips.new()
	pips.accent = accent
	pips.custom_minimum_size = Vector2(180, 8)
	pip_row.add_child(pips)
	var next_label: Label = _label("", 13, Palette.MUTED, _align())
	text_box.add_child(next_label)
	var buy: Button = UiKit.button(I18n.t("global_buy"), accent.darkened(0.28))
	buy.custom_minimum_size = Vector2(118, 52)
	buy.add_theme_font_size_override("font_size", 15)
	buy.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	buy.pressed.connect(_buy.bind(track))
	row.add_child(buy)
	_cards[track] = {
		"card": card,
		"accent": accent,
		"current": current_label,
		"pips": pips,
		"next": next_label,
		"buy": buy,
	}


func _build_help() -> void:
	var card := Panel.new()
	card.position = Vector2(20, 1028)
	card.size = Vector2(648, 170)
	card.add_theme_stylebox_override("panel", _help_style())
	_panel.add_child(card)
	var mark := TextureRect.new()
	mark.texture = Art.ui("star")
	mark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mark.position = Vector2(486, 26)
	mark.size = Vector2(132, 132)
	mark.modulate = Color(1, 1, 1, 0.06)
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(mark)
	var title: Label = _label(I18n.t("global_help_title"), 15, Palette.CYAN, _align())
	title.position = Vector2(18, 12)
	title.size = Vector2(420, 22)
	card.add_child(title)
	var help: Label = _label(I18n.t("global_help"), 13, Palette.MUTED, _align())
	help.position = Vector2(18, 38)
	help.size = Vector2(440, 116)
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	help.add_theme_constant_override("line_spacing", 4)
	card.add_child(help)


func _refresh_all() -> void:
	_refresh_header()
	_refresh_prestige()
	for track in GlobalUpgrades.TRACKS:
		_refresh_card(track)


func _refresh_header() -> void:
	_stars_label.text = str(SaveManager.blue_stars)
	_ascensions_label.text = I18n.t("global_ascensions") % SaveManager.ascensions
	_ascensions_label.text_direction = Control.TEXT_DIRECTION_RTL if I18n.is_fa() else Control.TEXT_DIRECTION_LTR


func _refresh_prestige() -> void:
	var built: int = SaveManager.cars_built
	var goal: int = SaveManager.CARS_FOR_PRESTIGE
	var reward: int = SaveManager.PRESTIGE_REWARD
	var ready: bool = SaveManager.can_prestige()
	_prestige_bar.value = float(mini(built, goal))
	_prestige_progress.text = I18n.t("cars_built") % [built, goal]
	_prestige_hint.text = (I18n.t("ascension_ready") % reward) if ready else (I18n.t("ascension_locked") % goal)
	_prestige_hint.add_theme_color_override("font_color", Palette.CYAN if ready else Palette.MUTED)
	_prestige_reward.text = I18n.t("ascension_reward") % reward
	if not ready:
		_confirm_until = 0
		_prestige_button.disabled = true
		_prestige_button.text = I18n.t("global_locked")
		_paint_button(_prestige_button, Palette.CYAN.darkened(0.35))
	elif _confirm_until > 0:
		_prestige_button.disabled = false
		_prestige_button.text = I18n.t("ascension_confirm")
		_paint_button(_prestige_button, Palette.BAD.darkened(0.35))
	else:
		_prestige_button.disabled = false
		_prestige_button.text = I18n.t("ascension_reset")
		_paint_button(_prestige_button, Palette.CYAN.darkened(0.35))


func _refresh_card(track: String) -> void:
	var data: Dictionary = _cards.get(track, {})
	if data.is_empty():
		return
	var level: int = SaveManager.global_level(track)
	var stars: int = SaveManager.blue_stars
	var maxed: bool = level >= GlobalUpgrades.MAX_LEVEL
	var cost: int = GlobalUpgrades.next_cost(track, level)
	var current: float = GlobalUpgrades.multiplier(track, level)
	var current_label: Label = data["current"]
	current_label.text = I18n.t("global_current") % GlobalUpgrades.format_multiplier(current)
	var pips: LevelPips = data["pips"]
	pips.set_level(level)
	var next_label: Label = data["next"]
	if maxed:
		next_label.text = I18n.t("global_max")
		next_label.add_theme_color_override("font_color", Palette.GOOD)
	else:
		var next_mult: float = GlobalUpgrades.multiplier(track, level + 1)
		next_label.text = "%s   ·   %s" % [
			I18n.t("global_next") % GlobalUpgrades.format_multiplier(next_mult),
			I18n.t("global_cost") % cost,
		]
		next_label.add_theme_color_override("font_color", Palette.GOOD if stars >= cost else Palette.MUTED)
	var buy: Button = data["buy"]
	buy.disabled = maxed or stars < cost
	buy.text = I18n.t("global_max") if maxed else I18n.t("global_buy")
	var accent: Color = data["accent"]
	var card: Panel = data["card"]
	card.add_theme_stylebox_override("panel", _card_style(accent, maxed))


func _buy(track: String) -> void:
	if SaveManager.buy_global(track):
		AudioManager.play("upgrade")
		AudioManager.haptic(10)
		_refresh_header()
		_refresh_prestige()
		for key in GlobalUpgrades.TRACKS:
			_refresh_card(key)
	else:
		AudioManager.play("deny")


func _on_prestige_pressed() -> void:
	if not SaveManager.can_prestige():
		AudioManager.play("deny")
		return
	var now: int = Time.get_ticks_msec()
	if _confirm_until == 0:
		_confirm_until = now + 3000
		AudioManager.play("click")
		_refresh_prestige()
		return
	if now > _confirm_until:
		_confirm_until = 0
		_refresh_prestige()
		return
	if SaveManager.prestige():
		_confirm_until = 0
		AudioManager.play("upgrade")
		AudioManager.haptic(30)
		prestiged.emit()
	else:
		AudioManager.play("deny")


func _close() -> void:
	closed.emit()


func _label(text: String, font_size: int, color: Color, align: HorizontalAlignment) -> Label:
	var label: Label = UiKit.label(text, font_size, color)
	label.horizontal_alignment = align
	return label


func _align() -> HorizontalAlignment:
	return HORIZONTAL_ALIGNMENT_RIGHT if I18n.is_fa() else HORIZONTAL_ALIGNMENT_LEFT


func _track_color(track: String) -> Color:
	match track:
		"price":
			return Palette.GOLD
		"speed":
			return Palette.CYAN
		"capacity":
			return Palette.GOOD
	return Palette.CYAN


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#0b1626")
	style.set_corner_radius_all(24)
	style.set_border_width_all(2)
	style.border_color = Color("#2b6188")
	style.shadow_color = Color(0, 0, 0, 0.6)
	style.shadow_size = 24
	style.shadow_offset = Vector2(0, 10)
	return style


func _chip_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(Palette.CYAN.r, Palette.CYAN.g, Palette.CYAN.b, 0.08)
	style.set_corner_radius_all(14)
	style.set_border_width_all(1)
	style.border_color = Color(Palette.CYAN.r, Palette.CYAN.g, Palette.CYAN.b, 0.55)
	return style


func _prestige_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#182b48")
	style.set_corner_radius_all(18)
	style.set_border_width_all(2)
	style.border_color = Color(Palette.GOLD.r, Palette.GOLD.g, Palette.GOLD.b, 0.65)
	style.shadow_color = Color(Palette.GOLD.r, Palette.GOLD.g, Palette.GOLD.b, 0.1)
	style.shadow_size = 10
	return style


func _card_style(accent: Color, maxed: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#12243b")
	style.set_corner_radius_all(18)
	style.set_border_width_all(2)
	style.border_color = (Palette.GOOD if maxed else Color(accent.r, accent.g, accent.b, 0.55))
	style.shadow_color = Color(0, 0, 0, 0.35)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 4)
	return style


func _icon_style(accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(accent.r, accent.g, accent.b, 0.1)
	style.set_corner_radius_all(16)
	style.set_border_width_all(1)
	style.border_color = Color(accent.r, accent.g, accent.b, 0.42)
	return style


func _help_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#0d1c2e")
	style.set_corner_radius_all(16)
	style.set_border_width_all(1)
	style.border_color = Color(Palette.PANEL_HIGH.r, Palette.PANEL_HIGH.g, Palette.PANEL_HIGH.b, 0.8)
	return style


func _bar_bg() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Palette.BG_DEEP
	style.set_corner_radius_all(6)
	style.set_border_width_all(1)
	style.border_color = Palette.PANEL_HIGH
	return style


func _bar_fill() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Palette.CYAN
	style.set_corner_radius_all(6)
	style.shadow_color = Color(Palette.CYAN.r, Palette.CYAN.g, Palette.CYAN.b, 0.4)
	style.shadow_size = 5
	return style


func _paint_button(button: Button, accent: Color) -> void:
	button.add_theme_stylebox_override("normal", _button_style(accent))
	button.add_theme_stylebox_override("hover", _button_style(accent.lightened(0.16)))
	button.add_theme_stylebox_override("pressed", _button_style(accent.darkened(0.22)))
	button.add_theme_stylebox_override("focus", _button_style(accent.lightened(0.2)))
	var disabled: StyleBoxFlat = _button_style(Palette.LOCKED)
	disabled.border_color = Palette.PANEL_HIGH
	button.add_theme_stylebox_override("disabled", disabled)


func _button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(12)
	style.set_border_width_all(2)
	style.border_color = color.lightened(0.18)
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 5
	style.shadow_offset = Vector2(0, 2)
	return style
