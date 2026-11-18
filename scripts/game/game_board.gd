class_name GameBoard
extends Control
## Sandbox factory: buy buildings, drag links, sell products at the market.

const DESIGN_SIZE: Vector2 = Vector2(720, 1280)
const HUD_SCENE: PackedScene = preload("res://scenes/ui/hud.tscn")
const AUTOSAVE_TIME: float = 3.0
const LINK_PICK_DISTANCE: float = 22.0

enum State { RUNNING, PAUSED }

var _stations: Dictionary = {}
var _links: Array[Link] = []
var _link_layer: Node2D
var _drag_line: DragLine
var _area: Control = Control.new()
var _factory: Control = Control.new()
var _hud: Hud
var _overlays: BoardOverlays = BoardOverlays.new()
var _fx: Fx = Fx.new()
var _state: State = State.RUNNING
var _base_pos: Vector2 = Vector2.ZERO
var _save_tick: float = 0.0
var _sell_fx_cd: float = 0.0
var _rr: Dictionary = {}
var _lane_counter: int = 0


func _ready() -> void:
	var bg := IndustrialBackground.new()
	bg.z_index = -1000
	add_child(bg)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_area.size = DESIGN_SIZE
	_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_factory.size = DESIGN_SIZE
	_factory.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_area)
	_area.add_child(_factory)
	_fx.z_index = 3
	_area.add_child(_fx)
	_hud = HUD_SCENE.instantiate()
	_hud.z_index = 5
	_area.add_child(_hud)
	_hud.pause_pressed.connect(_open_pause)
	_hud.global_pressed.connect(_open_global)
	add_child(_overlays)
	_overlays.resumed.connect(_on_resumed)
	_overlays.restart_requested.connect(_reload)
	_overlays.menu_requested.connect(_to_menu)
	_overlays.global_closed.connect(_on_global_closed)
	_overlays.prestige_requested.connect(_on_global_prestiged)
	SceneRouter.back_requested.connect(_open_pause)
	resized.connect(_on_resized)
	_on_resized()
	_build()


func _process(delta: float) -> void:
	if _state == State.RUNNING:
		_sell_fx_cd = maxf(_sell_fx_cd - delta, 0.0)
		for station: Station in _stations.values():
			station.step(delta)
		_distribute()
		for link in _links:
			link.step(delta)
		_update_affordable()
		_hud.set_tip(Tutorial.tip(_stations, _links, SaveManager.money))
		_save_tick += delta
		if _save_tick >= AUTOSAVE_TIME:
			_save_now()
	_update_drag_line()
	_hud.set_money(SaveManager.money)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_open_pause()
	elif event.is_action_pressed("restart"):
		_reload()


func _gui_input(event: InputEvent) -> void:
	if _state != State.RUNNING:
		return
	var mb := event as InputEventMouseButton
	if mb == null or not mb.pressed or mb.button_index != MOUSE_BUTTON_LEFT:
		return
	var point: Vector2 = mb.position - _area.position
	var link: Link = _link_at(point)
	if link != null:
		_cut_link(link)
		accept_event()


func _build() -> void:
	get_tree().paused = false
	_overlays.clear()
	_state = State.RUNNING
	_links.clear()
	_rr.clear()
	_lane_counter = 0
	for child in _factory.get_children():
		_factory.remove_child(child)
		child.queue_free()
	_link_layer = Node2D.new()
	_link_layer.name = "Links"
	_link_layer.z_index = -10
	_factory.add_child(_link_layer)
	_stations = FactoryBuilder.build(_factory, self)
	for station: Station in _stations.values():
		station.buy_requested.connect(_on_buy)
		station.produce_requested.connect(_on_produce)
		station.trait_requested.connect(_on_trait)
		station.produced.connect(_on_station_produced)
	_drag_line = DragLine.new()
	_drag_line.z_index = 4
	_factory.add_child(_drag_line)
	_restore_links()
	_hud.set_money(SaveManager.money)
	_hud.set_tip(Tutorial.tip(_stations, _links, SaveManager.money))


func _restore_links() -> void:
	for entry in SaveManager.links:
		var from_id: String = str(entry.get("from", ""))
		var to_id: String = str(entry.get("to", ""))
		var from_station: Station = _stations.get(from_id) as Station
		var to_station: Station = _stations.get(to_id) as Station
		if from_station == null or to_station == null:
			continue
		if from_station.locked or to_station.locked:
			continue
		if not _compatible(from_station, to_station):
			continue
		if _has_link(from_id, to_id):
			continue
		_add_link(from_station, to_station, false)


func _distribute() -> void:
	for id in _stations:
		var source: Station = _stations[id]
		if source.locked or source.data.is_market or source.output_count <= 0:
			continue
		var outgoing: Array[Link] = []
		for link in _links:
			if link.from == source:
				outgoing.append(link)
		if outgoing.is_empty():
			continue
		var index: int = int(_rr.get(id, 0)) % outgoing.size()
		var attempts: int = 0
		var limit: int = outgoing.size() * 10
		while source.output_count > 0 and attempts < limit:
			var link: Link = outgoing[index % outgoing.size()]
			if link.can_pull():
				link.pull_one()
				source.output_count -= 1
				index += 1
				_rr[id] = index % outgoing.size()
			else:
				index += 1
			attempts += 1
			if attempts >= limit:
				break


func _update_affordable() -> void:
	for station: Station in _stations.values():
		if station.locked:
			var affordable: bool = SaveManager.money >= station.data.buy_cost
			if affordable != station.affordable:
				station.affordable = affordable
				station.queue_redraw()
			continue
		if station.data.is_market:
			continue
		var changed: bool = false
		for key in SaveManager.TRAIT_KEYS:
			if station.is_trait_max(key):
				continue
			var cost: int = station.trait_cost(key)
			var can_buy: bool = cost > 0 and SaveManager.money >= cost
			if bool(station.trait_affordable.get(key, false)) != can_buy:
				station.trait_affordable[key] = can_buy
				changed = true
		if changed:
			station.queue_redraw()


func _update_drag_line() -> void:
	if _drag_line == null:
		return
	var viewport := get_viewport()
	if _state != State.RUNNING or not viewport.gui_is_dragging():
		_drag_line.clear()
		return
	var data: Variant = viewport.gui_get_drag_data()
	if typeof(data) != TYPE_DICTIONARY:
		_drag_line.clear()
		return
	var source: Station = data.get("source") as Station
	if source == null or not is_instance_valid(source):
		_drag_line.clear()
		return
	var mouse: Vector2 = _factory.get_local_mouse_position()
	var target: Station = _station_at(mouse)
	var ok: bool = target != null and can_connect(source, target)
	_drag_line.set_line(source.center(), mouse, ok)


func can_start_drag(source: Station) -> bool:
	return _state == State.RUNNING and source != null and not source.locked \
		and not source.data.is_market and source.data.output_item != ""


func can_connect(source: Station, target: Station) -> bool:
	if _state != State.RUNNING or source == null or target == null or source == target:
		return false
	if source.locked or target.locked:
		return false
	if not _compatible(source, target):
		return false
	return not _has_link(source.data.id, target.data.id)


func _compatible(source: Station, target: Station) -> bool:
	var product: String = source.data.output_item
	if product == "" or source.data.is_market:
		return false
	if target.data.is_market:
		return Economy.is_sellable(product)
	return target.data.input_item == product


func connect_stations(source: Station, target: Station) -> void:
	if not can_connect(source, target):
		if target != null:
			target.deny()
		AudioManager.play("deny")
		return
	_add_link(source, target, true)
	AudioManager.play("click")
	_fx.burst(target.center(), Economy.color(source.data.output_item))
	SaveManager.save_game()


func _add_link(source: Station, target: Station, save: bool) -> void:
	if not _compatible(source, target):
		return
	if _has_link(source.data.id, target.data.id):
		return
	var link := Link.new()
	link.name = "Link_%s_%s" % [source.data.id, target.data.id]
	_link_layer.add_child(link)
	link.setup(source, target, self, _lane_counter)
	_lane_counter += 1
	_links.append(link)
	if save:
		SaveManager.add_link(source.data.id, target.data.id)


func _cut_link(link: Link) -> void:
	if link == null or link.from == null or link.to == null:
		return
	SaveManager.remove_link(link.from.data.id, link.to.data.id)
	_links.erase(link)
	link.queue_free()
	AudioManager.play("deny")
	SaveManager.save_game()


func _link_at(point: Vector2) -> Link:
	var best: Link = null
	var best_distance: float = LINK_PICK_DISTANCE
	for link in _links:
		var distance: float = link.distance_to(point)
		if distance <= best_distance:
			best_distance = distance
			best = link
	return best


func obstacle_rects(a: Station, b: Station) -> Array[Rect2]:
	var rects: Array[Rect2] = []
	for station: Station in _stations.values():
		if station == a or station == b:
			continue
		rects.append(Rect2(station.position - Vector2(10, 10), station.size + Vector2(20, 20)))
	return rects


func _station_at(point: Vector2) -> Station:
	for station: Station in _stations.values():
		if Rect2(station.position, station.size).has_point(point):
			return station
	return null


func _has_link(from_id: String, to_id: String) -> bool:
	for link in _links:
		if link.from != null and link.to != null:
			if link.from.data.id == from_id and link.to.data.id == to_id:
				return true
	return false


func sell_product(product: String, market: Station, source: Station = null) -> void:
	var multiplier: float = source.sell_multiplier() if source != null else 1.0
	var price: int = maxi(roundi(float(Economy.sell_price(product)) * multiplier), 1)
	if price <= 0:
		return
	SaveManager.add_money(price)
	if _sell_fx_cd <= 0.0:
		_sell_fx_cd = 0.12
		_hud.pop_cash()
		var center: Vector2 = market.center()
		_fx.burst(center - Vector2(0, 60), Economy.color(product))
		_fx.float_text(center - Vector2(0, 82), "+$%d" % price, Economy.color(product))
		AudioManager.play("sell")


func _on_station_produced(item: String) -> void:
	if item != "cars":
		return
	var before: int = SaveManager.cars_built
	SaveManager.add_cars_built()
	if before < SaveManager.CARS_FOR_PRESTIGE and SaveManager.can_prestige():
		_hud.flash_tip(I18n.t("tip_prestige"), 4.5)
		AudioManager.play("upgrade")
		_fx.burst(Vector2(360, 420), Palette.CYAN)


func _on_buy(station: Station) -> void:
	if station == null or not station.locked:
		return
	var cost: int = station.data.buy_cost
	if not SaveManager.spend(cost):
		station.deny()
		AudioManager.play("deny")
		return
	SaveManager.unlock(station.data.id)
	station.set_unlocked()
	station.punch()
	_fx.burst(station.center(), Palette.GOOD)
	AudioManager.play("upgrade")
	SaveManager.save_game()
	_update_affordable()
	_hud.set_tip(Tutorial.tip(_stations, _links, SaveManager.money))


func _on_produce(station: Station) -> void:
	if station == null or station.locked or station.is_auto():
		return
	if station.manual_produce():
		AudioManager.play("dig" if station.data.id == "mine" else "click")
	else:
		station.deny()
		AudioManager.play("deny")


func _on_trait(station: Station, kind: String) -> void:
	if station == null or station.locked or station.data.is_market:
		return
	if station.is_trait_max(kind):
		return
	var cost: int = station.trait_cost(kind)
	if cost < 0 or not SaveManager.spend(cost):
		station.deny()
		AudioManager.play("deny")
		return
	station.apply_trait(kind)
	SaveManager.set_trait_level(station.data.id, kind, station.trait_level(kind))
	SaveManager.save_game()
	station.punch()
	_fx.burst(station.center(), Palette.GOOD)
	AudioManager.play("upgrade")
	AudioManager.haptic(10)
	_update_affordable()
	_hud.set_tip(Tutorial.tip(_stations, _links, SaveManager.money))


func _open_pause() -> void:
	if _state != State.RUNNING:
		return
	_save_now()
	_state = State.PAUSED
	get_tree().paused = true
	_overlays.open_pause(self)


func _open_global() -> void:
	if _state != State.RUNNING:
		return
	_save_now()
	_state = State.PAUSED
	get_tree().paused = true
	_overlays.open_global(self)


func _on_global_closed() -> void:
	get_tree().paused = false
	_state = State.RUNNING
	_overlays.clear()
	for station: Station in _stations.values():
		station.queue_redraw()
	_hud.queue_redraw()


func _on_global_prestiged() -> void:
	_build()
	var reward: int = SaveManager.PRESTIGE_REWARD
	_hud.flash_tip(I18n.t("prestige_done") % reward, 4.5)
	_fx.burst(Vector2(360, 560), Palette.CYAN)
	_fx.float_text(Vector2(360, 500), I18n.t("prestige_float") % reward, Palette.CYAN)


func _on_resumed() -> void:
	get_tree().paused = false
	_state = State.RUNNING
	_overlays.clear()


func _reload() -> void:
	_save_now()
	get_tree().paused = false
	_build()


func _to_menu() -> void:
	_save_now()
	SceneRouter.go(GameState.MENU_SCENE)


func _save_now() -> void:
	SaveManager.save_game()
	_save_tick = 0.0


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_save_now()
		_open_pause()
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_now()


func _on_resized() -> void:
	_base_pos = Vector2(floor((size.x - DESIGN_SIZE.x) * 0.5), 0.0)
	_area.position = _base_pos
