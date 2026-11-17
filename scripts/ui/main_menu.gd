class_name MainMenu
extends Control
## Title screen: Play, Settings, Quit (desktop only).

const SETTINGS_SCENE: PackedScene = preload("res://scenes/ui/settings_menu.tscn")

var _settings: SettingsMenu


func _ready() -> void:
	var bg := IndustrialBackground.new()
	bg.z_index = -1000
	add_child(bg)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var col: VBoxContainer = UiKit.panel_in_center(self)
	col.add_child(UiKit.label("IRON CHAIN", 64, Palette.WARN))
	col.add_child(UiKit.label(I18n.t("subtitle"), 28, Palette.MUTED))
	var line := ColorRect.new()
	line.color = Color(Palette.WARN.r, Palette.WARN.g, Palette.WARN.b, 0.5)
	line.custom_minimum_size = Vector2(360, 2)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(line)
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 26)
	col.add_child(spacer)
	UiKit.add_button(col, I18n.t("play"), _play, Palette.GOOD.darkened(0.4))
	UiKit.add_button(col, I18n.t("settings"), _open_settings)
	if not OS.has_feature("mobile"):
		UiKit.add_button(col, I18n.t("quit"), _quit, Palette.BAD.darkened(0.55))
	var progress: Label = UiKit.label(I18n.t("buildings") % [SaveManager.unlocked.size(), SaveManager.TOTAL_STATIONS], 24, Palette.MUTED)
	progress.text_direction = Control.TEXT_DIRECTION_LTR
	col.add_child(progress)
	var version: String = str(ProjectSettings.get_setting("application/config/version", "dev"))
	col.add_child(UiKit.label("v%s" % version, 18, Palette.MUTED))
	SceneRouter.back_requested.connect(_on_back)


func _play() -> void:
	SceneRouter.go(GameState.BOARD_SCENE)


func _open_settings() -> void:
	if is_instance_valid(_settings):
		return
	_settings = SETTINGS_SCENE.instantiate()
	add_child(_settings)
	_settings.closed.connect(func() -> void: _settings = null)


func _on_back() -> void:
	if is_instance_valid(_settings):
		return
	get_tree().quit()


func _quit() -> void:
	get_tree().quit()
