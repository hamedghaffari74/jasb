class_name BoardOverlays
extends Node
## Tracks the pause menu for the sandbox board.

signal resumed
signal restart_requested
signal menu_requested
signal global_closed
signal prestige_requested

const PAUSE_SCENE: PackedScene = preload("res://scenes/ui/pause_menu.tscn")
const GLOBAL_SCENE: PackedScene = preload("res://scenes/ui/global_lab.tscn")

var _pause: PauseMenu
var _global: GlobalLab


func open_pause(host: Control) -> void:
	_pause = PAUSE_SCENE.instantiate()
	_pause.z_index = 100
	host.add_child(_pause)
	_pause.resume_pressed.connect(func() -> void: resumed.emit())
	_pause.restart_pressed.connect(func() -> void: restart_requested.emit())
	_pause.menu_pressed.connect(func() -> void: menu_requested.emit())


func open_global(host: Control) -> void:
	_global = GLOBAL_SCENE.instantiate()
	_global.z_index = 100
	host.add_child(_global)
	_global.closed.connect(func() -> void: global_closed.emit())
	_global.prestiged.connect(func() -> void: prestige_requested.emit())


func clear() -> void:
	if is_instance_valid(_pause):
		_pause.queue_free()
	_pause = null
	if is_instance_valid(_global):
		_global.queue_free()
	_global = null
