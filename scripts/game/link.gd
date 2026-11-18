class_name Link
extends Node2D
## A player-made connection. Curved so lines avoid other station cards.

const MAX_ITEMS: int = 6
const TRAVEL_TIME: float = 0.6
const SAMPLES: int = 24

var board: GameBoard
var from: Station
var to: Station
var product: String = ""
var color: Color = Color.WHITE
var items: Array[float] = []

var _path: PackedVector2Array = PackedVector2Array()
var _lengths: PackedFloat32Array = PackedFloat32Array()
var _total: float = 0.0
var _lane_seed: int = 0
var _anim: float = 0.0
var _base_color: Color = Color.WHITE
var _line_width: float = 5.0
var _pull_accum: float = 1.0
var _last_level: int = -1


func setup(from_station: Station, to_station: Station, board_ref: GameBoard, lane_seed: int = 0) -> void:
	from = from_station
	to = to_station
	board = board_ref
	_lane_seed = lane_seed
	product = from.data.output_item
	_base_color = Economy.color(product)
	color = _base_color
	_refresh_strength()
	_path = _build_path()
	_build_lengths()
	queue_redraw()


func strength_level() -> int:
	return from.speed_level if from != null else 0


func throughput() -> float:
	return (1.0 + 0.5 * float(strength_level())) * SaveManager.global_speed()


func _refresh_strength() -> void:
	if from == null:
		return
	var level: int = strength_level()
	if level == _last_level:
		return
	_last_level = level
	color = _base_color.lerp(Palette.GOLD, 0.14 * float(level))
	_line_width = 5.0 + 0.5 * float(level)


func can_pull() -> bool:
	return from != null and to != null and items.size() < item_capacity() and _pull_accum >= 1.0 and to.can_accept_item(product)


func item_capacity() -> int:
	return maxi(MAX_ITEMS, ceili(throughput() * TRAVEL_TIME) + 2)


func pull_one() -> void:
	items.append(0.0)
	_pull_accum -= 1.0
	queue_redraw()


func step(delta: float) -> void:
	if from == null or to == null:
		return
	_anim += delta
	_refresh_strength()
	_pull_accum = minf(_pull_accum + throughput() * delta, 2.0)
	for i in range(items.size() - 1, -1, -1):
		items[i] += delta / TRAVEL_TIME
		if items[i] >= 1.0:
			if _deposit():
				items.remove_at(i)
			else:
				items[i] = 1.0
	queue_redraw()


func _deposit() -> bool:
	if to.data.is_market:
		board.sell_product(product, to, from)
		return true
	return to.receive_item(product)


func distance_to(point: Vector2) -> float:
	var best: float = 1e20
	for i in range(_path.size() - 1):
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(point, _path[i], _path[i + 1])
		best = minf(best, point.distance_to(closest))
	return best


func _build_path() -> PackedVector2Array:
	var a: Vector2 = from.center()
	var b: Vector2 = to.center()
	var obstacles: Array[Rect2] = board.obstacle_rects(from, to)
	var candidates: Array[PackedVector2Array] = []
	candidates.append(PackedVector2Array([a, b]))
	var lanes: Array[float] = [360.0, 345.0, 375.0, 60.0, 660.0, 120.0, 600.0, 30.0, 690.0]
	var start: int = _lane_seed % lanes.size()
	for i in lanes.size():
		var lane: float = lanes[(start + i) % lanes.size()]
		candidates.append(PackedVector2Array([a, Vector2(lane, a.y), Vector2(lane, b.y), b]))
	for lane in [108.0, 1170.0]:
		candidates.append(PackedVector2Array([a, Vector2(a.x, lane), Vector2(b.x, lane), b]))
	candidates.append(PackedVector2Array([a, Vector2(a.x, b.y), b]))
	candidates.append(PackedVector2Array([a, Vector2(b.x, a.y), b]))
	for candidate in candidates:
		if _is_clear(candidate, obstacles):
			return candidate
	return candidates[0]


func _is_clear(points: PackedVector2Array, obstacles: Array[Rect2]) -> bool:
	for i in range(points.size() - 1):
		var a: Vector2 = points[i]
		var b: Vector2 = points[i + 1]
		var steps: int = maxi(int(a.distance_to(b) / 8.0), 1)
		for step in range(steps + 1):
			var point: Vector2 = a.lerp(b, float(step) / float(steps))
			if point.x < 18.0 or point.x > 702.0 or point.y < 100.0 or point.y > 1185.0:
				return false
			for rect in obstacles:
				if rect.has_point(point):
					return false
	return true


func _build_lengths() -> void:
	_lengths.clear()
	_total = 0.0
	if _path.size() < 2:
		return
	_lengths.append(0.0)
	for i in range(1, _path.size()):
		_total += _path[i - 1].distance_to(_path[i])
		_lengths.append(_total)


func _point_at(progress: float) -> Vector2:
	if _path.size() < 2 or _total <= 0.0:
		return from.center() if from != null else Vector2.ZERO
	var target: float = clampf(progress, 0.0, 1.0) * _total
	for i in range(1, _lengths.size()):
		if _lengths[i] >= target:
			var span: float = _lengths[i] - _lengths[i - 1]
			var t: float = (target - _lengths[i - 1]) / span if span > 0.0 else 0.0
			return _path[i - 1].lerp(_path[i], t)
	return _path[_path.size() - 1]


func _draw() -> void:
	if _path.size() < 2:
		return
	var pulse: float = 0.5 + 0.5 * sin(_anim * 3.0)
	var width: float = _line_width
	draw_polyline(_path, Color(color.r, color.g, color.b, 0.08 + pulse * 0.03), width * 4.0, true)
	draw_polyline(_path, Color(color.r, color.g, color.b, 0.18 + pulse * 0.05), width * 2.2, true)
	draw_polyline(_path, Color(color.r, color.g, color.b, 0.88), width, true)
	var moving: bool = not items.is_empty() or (from != null and from.working)
	if moving:
		var flow_speed: float = (0.35 + 0.06 * float(strength_level())) * (0.75 + 0.25 * SaveManager.global_speed())
		var flow: float = fmod(_anim * flow_speed, 1.0)
		var flow_pos: Vector2 = _point_at(flow)
		draw_circle(flow_pos, 11.0 + width, Color(color.r, color.g, color.b, 0.12))
		draw_circle(flow_pos, 4.0, Color(1, 1, 1, 0.75))
	var a: Vector2 = _path[_path.size() - 2]
	var b: Vector2 = _path[_path.size() - 1]
	var dir: Vector2 = a.direction_to(b)
	var normal := Vector2(-dir.y, dir.x)
	draw_colored_polygon(PackedVector2Array([
		b - dir * 12.0 + normal * 8.0,
		b - dir * 12.0 - normal * 8.0,
		b,
	]), color)
	draw_circle(_path[0], 4.0, Color(color.r, color.g, color.b, 0.9))
	draw_circle(b, 4.0, Color(color.r, color.g, color.b, 0.9))
	for p in items:
		var pos: Vector2 = _point_at(p)
		draw_circle(pos, 12.0 + width, Color(color.r, color.g, color.b, 0.14))
		draw_circle(pos, 7.0 + width * 0.2, color)
		draw_circle(pos, 2.5, Color(1, 1, 1, 0.85))
