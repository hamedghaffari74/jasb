class_name IndustrialBackground
extends Control
## Layered night-time factory skyline with animated smoke and warm windows.

var _time: float = 0.0
var _redraw_acc: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)


func _process(delta: float) -> void:
	_time += delta
	_redraw_acc += delta
	if _redraw_acc >= 0.033:
		_redraw_acc = 0.0
		queue_redraw()


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	if w <= 1.0 or h <= 1.0:
		return
	_draw_sky(w, h)
	_draw_stars(w, h)
	_draw_far_city(w, h)
	_draw_near_city(w, h)
	_draw_ground(w, h)
	_draw_vignette(w, h)


func _draw_sky(w: float, h: float) -> void:
	var top := Color("#0a1220")
	var bottom := Color("#172a44")
	var bands: int = 28
	for i in bands:
		var t: float = float(i) / float(bands - 1)
		var color: Color = top.lerp(bottom, t)
		draw_rect(Rect2(0.0, h * t, w, h / float(bands) + 2.0), color)
	draw_circle(Vector2(w * 0.80, h * 0.13), 120.0, Color(1.0, 0.67, 0.14, 0.035))
	draw_circle(Vector2(w * 0.80, h * 0.13), 54.0, Color(1.0, 0.82, 0.4, 0.09))
	draw_circle(Vector2(w * 0.80, h * 0.13), 22.0, Color(1.0, 0.9, 0.6, 0.22))


func _draw_stars(w: float, h: float) -> void:
	for i in 44:
		var x: float = fposmod(float(i) * 137.5 + 31.0, w)
		var y: float = fposmod(float(i) * 79.3 + 17.0, h * 0.48)
		var twinkle: float = 0.35 + 0.25 * sin(_time * 1.3 + float(i))
		draw_circle(Vector2(x, y), 1.1, Color(0.72, 0.83, 1.0, twinkle))


func _draw_far_city(w: float, h: float) -> void:
	var base: float = h * 0.58
	var color := Color("#0d192a")
	var color2 := Color("#101f34")
	var buildings: Array[Vector2] = [
		Vector2(0, 120), Vector2(68, 82), Vector2(124, 150), Vector2(196, 96),
		Vector2(250, 128), Vector2(322, 72), Vector2(380, 138), Vector2(456, 104),
		Vector2(522, 160), Vector2(602, 92), Vector2(660, 132), Vector2(720, 86),
	]
	for i in buildings.size():
		var b: Vector2 = buildings[i]
		var brick: Color = color if i % 2 == 0 else color2
		draw_rect(Rect2(b.x, base - b.y, w * 0.14 + 36.0, b.y + 2.0), brick)
		draw_rect(Rect2(b.x + 14.0, base - b.y - 28.0, 12.0, 30.0), brick.darkened(0.1))
		for row in 4:
			for col in 3:
				if (row + col + i) % 3 == 0:
					continue
				var wx: float = b.x + 12.0 + col * 22.0
				var wy: float = base - b.y + 16.0 + row * 22.0
				var warm: Color = Color(1.0, 0.67, 0.25, 0.22 + 0.08 * sin(_time + float(i + row)))
				draw_rect(Rect2(wx, wy, 7.0, 10.0), warm)


func _draw_near_city(w: float, h: float) -> void:
	var base: float = h * 0.72
	var color := Color("#111f33")
	var buildings: Array[Vector2] = [
		Vector2(-20, 190), Vector2(46, 130), Vector2(112, 220), Vector2(188, 150),
		Vector2(258, 180), Vector2(330, 120), Vector2(400, 240), Vector2(484, 160),
		Vector2(560, 200), Vector2(636, 140), Vector2(700, 220),
	]
	for i in buildings.size():
		var b: Vector2 = buildings[i]
		draw_rect(Rect2(b.x, base - b.y, w * 0.16 + 46.0, b.y + 2.0), color)
		var chimney_x: float = b.x + 26.0
		var chimney_h: float = 30.0 + float(i % 3) * 14.0
		draw_rect(Rect2(chimney_x, base - b.y - chimney_h, 14.0, chimney_h + 2.0), color.lightened(0.08))
		draw_rect(Rect2(chimney_x - 3.0, base - b.y - chimney_h, 20.0, 6.0), color.lightened(0.16))
		for row in 5:
			for col in 4:
				if (row * 3 + col + i) % 4 == 0:
					continue
				var wx: float = b.x + 18.0 + col * 26.0
				var wy: float = base - b.y + 20.0 + row * 24.0
				var warm: Color = Color(1.0, 0.62, 0.22, 0.18 + 0.1 * sin(_time * 0.7 + float(i + row + col)))
				draw_rect(Rect2(wx, wy, 8.0, 11.0), warm)
		_draw_smoke(Vector2(chimney_x + 7.0, base - b.y - chimney_h), float(i))
	draw_rect(Rect2(0.0, base + 4.0, w, h - base), Color("#0b1525"))


func _draw_smoke(origin: Vector2, seed: float) -> void:
	for i in 4:
		var t: float = fmod(_time * 0.055 + seed * 0.13 + float(i) * 0.24, 1.0)
		var pos: Vector2 = origin + Vector2(sin(_time * 0.7 + float(i) + seed) * 8.0, -t * 72.0)
		var radius: float = 5.0 + t * 14.0
		var alpha: float = (1.0 - t) * 0.075
		draw_circle(pos, radius, Color(0.62, 0.72, 0.84, alpha))


func _draw_ground(w: float, h: float) -> void:
	var top: float = h * 0.88
	draw_rect(Rect2(0.0, top, w, h - top), Color("#0a1220"))
	for i in 9:
		var y: float = top + float(i) * 14.0
		draw_line(Vector2(0.0, y), Vector2(w, y), Color(0.2, 0.35, 0.52, 0.06), 1.0)
	for i in 18:
		var x: float = fposmod(float(i) * 47.0, w)
		draw_line(Vector2(x, top), Vector2(x - 80.0, h), Color(0.2, 0.35, 0.52, 0.045), 1.0)


func _draw_vignette(w: float, h: float) -> void:
	draw_rect(Rect2(0.0, 0.0, w, 80.0), Color(0.0, 0.0, 0.0, 0.18))
	draw_rect(Rect2(0.0, h - 120.0, w, 120.0), Color(0.0, 0.0, 0.0, 0.2))
	draw_rect(Rect2(0.0, 0.0, 50.0, h), Color(0.0, 0.0, 0.0, 0.12))
	draw_rect(Rect2(w - 50.0, 0.0, 50.0, h), Color(0.0, 0.0, 0.0, 0.12))
