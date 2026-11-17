class_name Fx
extends Node2D
## Pooled particle bursts (max 8 x 12 = 96 particles) and floating texts.

const POOL_SIZE: int = 8

var _pool: Array[CPUParticles2D] = []
var _next: int = 0


func _ready() -> void:
	for i in POOL_SIZE:
		var p := CPUParticles2D.new()
		p.emitting = false
		p.one_shot = true
		p.amount = 12
		p.lifetime = 0.55
		p.explosiveness = 1.0
		p.direction = Vector2.UP
		p.spread = 70.0
		p.initial_velocity_min = 120.0
		p.initial_velocity_max = 260.0
		p.gravity = Vector2(0.0, 520.0)
		p.scale_amount_min = 4.0
		p.scale_amount_max = 8.0
		p.color_ramp = _fade()
		add_child(p)
		_pool.append(p)


func burst(pos: Vector2, color: Color) -> void:
	var p: CPUParticles2D = _pool[_next]
	_next = (_next + 1) % POOL_SIZE
	p.position = pos
	p.color = color
	p.restart()


func float_text(pos: Vector2, text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", color)
	label.position = pos - Vector2(40, 0)
	add_child(label)
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 60.0, 0.7)
	tween.tween_property(label, "modulate:a", 0.0, 0.7)
	tween.chain().tween_callback(label.queue_free)


func _fade() -> Gradient:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	return gradient
