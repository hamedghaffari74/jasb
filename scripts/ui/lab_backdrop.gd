class_name LabBackdrop
extends Control
## Static starfield/glow behind the global lab panel.


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	draw_circle(Vector2(size.x * 0.5, 0.0), 240.0, Color(0.12, 0.55, 0.95, 0.055))
	draw_circle(Vector2(size.x * 0.5, 0.0), 130.0, Color(0.25, 0.75, 1.0, 0.05))
	for i in 46:
		var x: float = fposmod(float(i) * 149.0 + 23.0, size.x)
		var y: float = fposmod(float(i) * 91.0 + 37.0, size.y)
		var alpha: float = 0.06 + 0.05 * float(i % 4)
		draw_circle(Vector2(x, y), 1.2, Color(0.55, 0.82, 1.0, alpha))
	for i in 8:
		var y: float = size.y - 24.0 - float(i) * 16.0
		draw_line(Vector2(24.0, y), Vector2(size.x - 24.0, y), Color(0.2, 0.5, 0.8, 0.045), 1.0)
