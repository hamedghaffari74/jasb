class_name LevelPips
extends Control
## Five small level pips used by the global lab cards.

var level: int = 0
var accent: Color = Palette.CYAN:
	set(value):
		accent = value
		queue_redraw()

var _pip_style: StyleBoxFlat = StyleBoxFlat.new()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(0, 8)
	_pip_style.set_corner_radius_all(3)


func set_level(value: int) -> void:
	level = clampi(value, 0, 5)
	queue_redraw()


func _draw() -> void:
	var gap: float = 4.0
	var width: float = (size.x - gap * 4.0) / 5.0
	for i in 5:
		_pip_style.bg_color = accent if i < level else Color(Palette.PANEL_HIGH.r, Palette.PANEL_HIGH.g, Palette.PANEL_HIGH.b, 0.65)
		draw_style_box(_pip_style, Rect2(float(i) * (width + gap), 0.0, width, size.y))
