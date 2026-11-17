class_name DragLine
extends Node2D
## Green/red preview line while dragging from a factory to a target.

var active: bool = false
var color: Color = Palette.GOOD
var a: Vector2 = Vector2.ZERO
var b: Vector2 = Vector2.ZERO


func set_line(from_pos: Vector2, to_pos: Vector2, ok: bool) -> void:
	active = true
	a = from_pos
	b = to_pos
	color = Palette.GOOD if ok else Palette.BAD
	queue_redraw()


func clear() -> void:
	if not active:
		return
	active = false
	queue_redraw()


func _draw() -> void:
	if not active:
		return
	draw_line(a, b, color, 6.0)
	var dir: Vector2 = a.direction_to(b)
	var normal := Vector2(-dir.y, dir.x)
	draw_colored_polygon(PackedVector2Array([
		b - dir * 10.0 + normal * 6.0,
		b - dir * 10.0 - normal * 6.0,
		b,
	]), color)
