class_name FactoryBuilder
extends RefCounted
## Instantiates every building once; locked ones stay visible and buyable.

const STATION_SCENE: PackedScene = preload("res://scenes/game/station.tscn")
const STATION_PATH: String = "res://resources/stations/%s.tres"

const LAYOUT: Dictionary = {
	"mine": Vector2(170, 215),
	"smelter": Vector2(170, 445),
	"mill": Vector2(170, 675),
	"tool_shop": Vector2(170, 905),
	"market": Vector2(550, 215),
	"car_plant": Vector2(550, 445),
	"appliance_plant": Vector2(550, 675),
}

const SIZES: Dictionary = {
	"mine": Vector2(330, 215),
	"smelter": Vector2(330, 215),
	"mill": Vector2(330, 215),
	"market": Vector2(330, 215),
	"tool_shop": Vector2(330, 215),
	"car_plant": Vector2(330, 215),
	"appliance_plant": Vector2(330, 215),
}


static func build(parent: Control, board: GameBoard) -> Dictionary:
	var stations: Dictionary = {}
	for key in LAYOUT:
		var id: String = key
		var station: Station = STATION_SCENE.instantiate()
		station.size = SIZES[id]
		station.position = LAYOUT[id] - station.size * 0.5
		parent.add_child(station)
		var data: StationData = load(STATION_PATH % id) as StationData
		station.setup(data, not SaveManager.is_unlocked(id), board, SaveManager.get_traits(id))
		stations[id] = station
	return stations
