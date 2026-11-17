class_name SettingsMenu
extends Control
## Overlay: sound, music, vibration, reset progress. Used by menu and pause.

signal closed

var _confirm_reset: bool = false
var _closing: bool = false
var _reset_button: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	UiKit.add_dim(self)
	var col: VBoxContainer = UiKit.panel_in_center(self)
	col.add_child(UiKit.label(I18n.t("settings_title"), 48, Palette.TEXT))
	_add_slider(col, I18n.t("sound"), "sfx")
	_add_slider(col, I18n.t("music"), "music")
	var haptics := CheckButton.new()
	haptics.text = I18n.t("vibration")
	haptics.text_direction = Control.TEXT_DIRECTION_RTL if I18n.is_fa() else Control.TEXT_DIRECTION_AUTO
	haptics.button_pressed = bool(SaveManager.settings.get("haptics", true))
	haptics.add_theme_font_size_override("font_size", 28)
	haptics.add_theme_color_override("font_color", Palette.TEXT)
	haptics.add_theme_color_override("font_hover_color", Palette.TEXT)
	haptics.toggled.connect(func(on: bool) -> void: SaveManager.set_setting("haptics", on))
	col.add_child(haptics)
	col.add_child(UiKit.label(I18n.t("language"), 26, Palette.MUTED))
	var language := OptionButton.new()
	language.custom_minimum_size = Vector2(440, 48)
	language.text_direction = Control.TEXT_DIRECTION_RTL if I18n.is_fa() else Control.TEXT_DIRECTION_AUTO
	language.add_theme_font_size_override("font_size", 24)
	language.add_theme_color_override("font_color", Palette.TEXT)
	language.add_theme_color_override("font_hover_color", Palette.TEXT)
	language.add_theme_color_override("font_pressed_color", Palette.TEXT)
	language.add_theme_stylebox_override("normal", _input_box(Palette.PANEL_LIGHT))
	language.add_theme_stylebox_override("hover", _input_box(Palette.PANEL_HIGH))
	language.add_theme_stylebox_override("pressed", _input_box(Palette.PANEL_LIGHT))
	language.add_theme_stylebox_override("focus", UiKit._box(Palette.PANEL_LIGHT))
	language.add_item(I18n.t("persian"), 0)
	language.add_item(I18n.t("english"), 1)
	language.select(0 if I18n.is_fa() else 1)
	language.item_selected.connect(_on_language_selected)
	col.add_child(language)
	_reset_button = UiKit.add_button(col, I18n.t("reset"), _on_reset, Palette.BAD.darkened(0.5))
	UiKit.add_button(col, I18n.t("close"), close, Palette.GOOD.darkened(0.4))
	SceneRouter.back_requested.connect(close)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close()


func close() -> void:
	if _closing:
		return
	_closing = true
	SaveManager.save_game()
	closed.emit()
	queue_free()


func _add_slider(parent: Control, title: String, key: String) -> void:
	parent.add_child(UiKit.label(title, 26, Palette.MUTED))
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = float(SaveManager.settings.get(key, 0.8))
	slider.custom_minimum_size = Vector2(440, 40)
	slider.add_theme_stylebox_override("slider", _track_box(Palette.BELT))
	slider.add_theme_stylebox_override("grabber_area", _track_box(Palette.GOOD.darkened(0.15)))
	slider.add_theme_stylebox_override("grabber_area_highlight", _track_box(Palette.GOOD))
	slider.value_changed.connect(func(v: float) -> void: SaveManager.set_setting(key, v))
	slider.drag_ended.connect(func(_changed: bool) -> void: AudioManager.play("click"))
	parent.add_child(slider)


func _track_box(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(4)
	style.set_content_margin_all(4.0)
	return style


func _input_box(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(8)
	style.set_border_width_all(1)
	style.border_color = Palette.PANEL_HIGH
	style.set_content_margin_all(8.0)
	return style


func _on_reset() -> void:
	if not _confirm_reset:
		_confirm_reset = true
		_reset_button.text = I18n.t("confirm")
		return
	SaveManager.reset_progress()
	SceneRouter.go(GameState.MENU_SCENE)


func _on_language_selected(index: int) -> void:
	var code: String = "fa" if index == 0 else "en"
	if code == I18n.language:
		return
	SaveManager.set_setting("language", code)
	SaveManager.save_game()
	var current: Node = get_tree().current_scene
	var path: String = current.scene_file_path if current != null else ""
	if path == "":
		path = GameState.MENU_SCENE
	SceneRouter.go(path, true)
