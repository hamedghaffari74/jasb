class_name PauseMenu
extends Control
## Overlay shown while the tree is paused (runs with PROCESS_MODE_ALWAYS).

signal resume_pressed
signal restart_pressed
signal menu_pressed

const SETTINGS_SCENE: PackedScene = preload("res://scenes/ui/settings_menu.tscn")

var _opened_ms: int = 0
var _settings: SettingsMenu


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_opened_ms = Time.get_ticks_msec()
	UiKit.add_dim(self)
	var col: VBoxContainer = UiKit.panel_in_center(self)
	col.add_child(UiKit.label(I18n.t("paused"), 50, Palette.TEXT))
	var first: Button = UiKit.add_button(col, I18n.t("resume"), _resume, Palette.GOOD.darkened(0.4))
	UiKit.add_button(col, I18n.t("restart"), func() -> void: restart_pressed.emit())
	UiKit.add_button(col, I18n.t("settings"), _open_settings)
	UiKit.add_button(col, I18n.t("quit_menu"), func() -> void: menu_pressed.emit())
	first.grab_focus()
	SceneRouter.back_requested.connect(_resume)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_resume()


func _resume() -> void:
	var too_early: bool = Time.get_ticks_msec() - _opened_ms < 250
	if too_early or is_instance_valid(_settings):
		return
	resume_pressed.emit()


func _open_settings() -> void:
	if is_instance_valid(_settings):
		return
	_settings = SETTINGS_SCENE.instantiate()
	add_child(_settings)
	_settings.closed.connect(func() -> void: _settings = null)
