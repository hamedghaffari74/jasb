extends Node
## Boot shell: fits the desktop window to the monitor, then opens the menu.

const DESKTOP_SIZE: Vector2i = Vector2i(540, 960)
const WINDOW_MARGIN: int = 8


func _ready() -> void:
	_fit_window()
	SceneRouter.go.call_deferred(GameState.MENU_SCENE, true)


func _fit_window() -> void:
	if OS.has_feature("mobile") or DisplayServer.get_name() == "headless":
		return
	var screen: int = DisplayServer.window_get_current_screen()
	var usable: Rect2i = DisplayServer.screen_get_usable_rect(screen)
	if usable.size.x <= 0 or usable.size.y <= 0:
		usable = Rect2i(Vector2i.ZERO, DisplayServer.screen_get_size(screen))
	var frame: Vector2i = DisplayServer.window_get_size_with_decorations() - DisplayServer.window_get_size()
	var max_size := Vector2i(
		maxi(usable.size.x - frame.x - WINDOW_MARGIN * 2, 320),
		maxi(usable.size.y - frame.y - WINDOW_MARGIN * 2, 480)
	)
	var fit: float = minf(1.0, minf(float(max_size.x) / float(DESKTOP_SIZE.x), float(max_size.y) / float(DESKTOP_SIZE.y)))
	var window_size := Vector2i(roundi(DESKTOP_SIZE.x * fit), roundi(DESKTOP_SIZE.y * fit))
	DisplayServer.window_set_size(window_size)
	frame = DisplayServer.window_get_size_with_decorations() - DisplayServer.window_get_size()
	var title: int = maxi(frame.y - 8, 24)
	DisplayServer.window_set_position(Vector2i(
		usable.position.x + (usable.size.x - window_size.x - frame.x) / 2 + frame.x / 2,
		usable.position.y + WINDOW_MARGIN + title
	))
