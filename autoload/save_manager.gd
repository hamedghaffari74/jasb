extends Node
## Sandbox save: money, bought buildings, per-building options and links.

signal settings_changed

const SAVE_PATH: String = "user://save.json"
const VERSION: int = 5
const TOTAL_STATIONS: int = 7
const START_UNLOCKED: Array[String] = ["mine", "market"]
const TRAIT_KEYS: Array[String] = ["speed", "price", "space", "auto"]
const CARS_FOR_PRESTIGE: int = 100
const PRESTIGE_REWARD: int = 50

var money: int = 0
var unlocked: Array[String] = []
var traits: Dictionary = {}
var links: Array[Dictionary] = []
var settings: Dictionary = {}
var blue_stars: int = 0
var global_levels: Dictionary = {}
var cars_built: int = 0
var ascensions: int = 0


func _ready() -> void:
	load_game()
	I18n.set_language(str(settings.get("language", "fa")))


func load_game() -> void:
	_reset()
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var data: Dictionary = parsed
	if int(data.get("version", 0)) != VERSION:
		return
	money = maxi(int(data.get("money", 0)), 0)
	var raw_unlocked: Variant = data.get("unlocked", [])
	if raw_unlocked is Array:
		unlocked.clear()
		for value in raw_unlocked:
			var id: String = str(value)
			if id != "" and not unlocked.has(id):
				unlocked.append(id)
	for id in START_UNLOCKED:
		if not unlocked.has(id):
			unlocked.append(id)
	traits.clear()
	var raw_traits: Variant = data.get("traits", {})
	if raw_traits is Dictionary:
		for raw_id in raw_traits:
			var id: String = str(raw_id)
			var raw_owned: Variant = raw_traits[raw_id]
			if raw_owned is Dictionary:
				var owned: Dictionary = {}
				for key in raw_owned:
					var trait_key: String = str(key)
					if not TRAIT_KEYS.has(trait_key):
						continue
					var raw_value: Variant = raw_owned[key]
					var value: int = 0
					if raw_value is bool:
						value = 1 if raw_value else 0
					else:
						value = int(raw_value)
					var maximum: int = 1 if trait_key == "auto" else 5
					owned[trait_key] = clampi(value, 0, maximum)
				traits[id] = owned
	for id in unlocked:
		if not traits.has(id):
			traits[id] = {}
	var raw_links: Variant = data.get("links", [])
	links.clear()
	if raw_links is Array:
		for entry in raw_links:
			var from_id: String = ""
			var to_id: String = ""
			if entry is Dictionary:
				from_id = str(entry.get("from", ""))
				to_id = str(entry.get("to", ""))
			elif entry is Array and entry.size() >= 2:
				from_id = str(entry[0])
				to_id = str(entry[1])
			if from_id != "" and to_id != "" and from_id != to_id:
				links.append({"from": from_id, "to": to_id})
	var raw_settings: Variant = data.get("settings", {})
	if raw_settings is Dictionary:
		for key in raw_settings:
			settings[key] = raw_settings[key]
	blue_stars = maxi(int(data.get("blue_stars", 0)), 0)
	cars_built = maxi(int(data.get("cars_built", 0)), 0)
	ascensions = maxi(int(data.get("ascensions", 0)), 0)
	global_levels = _default_global_levels()
	var raw_globals: Variant = data.get("global_levels", {})
	if raw_globals is Dictionary:
		for track in GlobalUpgrades.TRACKS:
			global_levels[track] = clampi(int(raw_globals.get(track, 0)), 0, GlobalUpgrades.MAX_LEVEL)
	I18n.set_language(str(settings.get("language", "fa")))


func save_game() -> void:
	var data: Dictionary = {
		"version": VERSION,
		"money": money,
		"unlocked": unlocked,
		"traits": traits,
		"links": links,
		"settings": settings,
		"blue_stars": blue_stars,
		"global_levels": global_levels,
		"cars_built": cars_built,
		"ascensions": ascensions,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))


func is_unlocked(id: String) -> bool:
	return unlocked.has(id)


func unlock(id: String) -> void:
	if id != "" and not unlocked.has(id):
		unlocked.append(id)
	if id != "" and not traits.has(id):
		traits[id] = {}


func get_traits(id: String) -> Dictionary:
	var value: Variant = traits.get(id, {})
	return value if value is Dictionary else {}


func get_trait_level(id: String, key: String) -> int:
	return clampi(int(get_traits(id).get(key, 0)), 0, 5)


func has_trait(id: String, key: String) -> bool:
	return get_trait_level(id, key) > 0


func set_trait_level(id: String, key: String, value: int) -> void:
	if not traits.has(id):
		traits[id] = {}
	var owned: Dictionary = traits[id]
	if TRAIT_KEYS.has(key):
		var maximum: int = 1 if key == "auto" else 5
		owned[key] = clampi(value, 0, maximum)


func add_money(amount: int) -> void:
	if amount > 0:
		money += amount


func spend(amount: int) -> bool:
	if amount <= 0:
		return true
	if money < amount:
		return false
	money -= amount
	return true


func add_link(from_id: String, to_id: String) -> void:
	if from_id == "" or to_id == "" or from_id == to_id:
		return
	for link in links:
		if str(link.get("from", "")) == from_id and str(link.get("to", "")) == to_id:
			return
	links.append({"from": from_id, "to": to_id})


func remove_link(from_id: String, to_id: String) -> void:
	for i in range(links.size() - 1, -1, -1):
		var link: Dictionary = links[i]
		if str(link.get("from", "")) == from_id and str(link.get("to", "")) == to_id:
			links.remove_at(i)


func has_link(from_id: String, to_id: String) -> bool:
	for link in links:
		if str(link.get("from", "")) == from_id and str(link.get("to", "")) == to_id:
			return true
	return false


func set_setting(key: String, value: Variant) -> void:
	settings[key] = value
	if key == "language":
		I18n.set_language(str(value))
	settings_changed.emit()


func global_level(track: String) -> int:
	return clampi(int(global_levels.get(track, 0)), 0, GlobalUpgrades.MAX_LEVEL)


func global_multiplier(track: String) -> float:
	return GlobalUpgrades.multiplier(track, global_level(track))


func global_price() -> float:
	return global_multiplier("price")


func global_speed() -> float:
	return global_multiplier("speed")


func global_capacity() -> float:
	return global_multiplier("capacity")


func add_cars_built(count: int = 1) -> void:
	if count > 0:
		cars_built += count


func can_prestige() -> bool:
	return cars_built >= CARS_FOR_PRESTIGE


func prestige() -> bool:
	if not can_prestige():
		return false
	_reset_run()
	blue_stars += PRESTIGE_REWARD
	ascensions += 1
	save_game()
	return true


func buy_global(track: String) -> bool:
	if not GlobalUpgrades.TRACKS.has(track):
		return false
	var level: int = global_level(track)
	if level >= GlobalUpgrades.MAX_LEVEL:
		return false
	var cost: int = GlobalUpgrades.next_cost(track, level)
	if cost <= 0 or blue_stars < cost:
		return false
	blue_stars -= cost
	global_levels[track] = level + 1
	save_game()
	return true


func reset_progress() -> void:
	var keep: Dictionary = settings.duplicate()
	_reset()
	settings = keep
	I18n.set_language(str(settings.get("language", "fa")))
	save_game()


func _reset() -> void:
	_reset_run()
	blue_stars = 0
	global_levels = _default_global_levels()
	ascensions = 0
	settings = {"sfx": 0.8, "music": 0.6, "haptics": true, "language": "fa"}


func _reset_run() -> void:
	money = 0
	unlocked.clear()
	for id in START_UNLOCKED:
		unlocked.append(id)
	traits.clear()
	for id in START_UNLOCKED:
		traits[id] = {}
	links.clear()
	cars_built = 0


func _default_global_levels() -> Dictionary:
	var levels: Dictionary = {}
	for track in GlobalUpgrades.TRACKS:
		levels[track] = 0
	return levels
