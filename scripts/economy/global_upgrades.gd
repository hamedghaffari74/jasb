class_name GlobalUpgrades
extends RefCounted
## Permanent lab tracks bought with blue stars. Data only; SaveManager owns state.

const TRACKS: Array[String] = ["price", "speed", "capacity"]
const MAX_LEVEL: int = 5
const COSTS: Array[int] = [10, 25, 60, 150, 400]

const MULTIPLIERS: Dictionary = {
	"price": [1.0, 2.0, 5.0, 10.0, 25.0, 50.0],
	"speed": [1.0, 1.25, 1.5, 2.0, 3.0, 5.0],
	"capacity": [1.0, 1.25, 1.5, 2.0, 3.0, 4.0],
}


static func multiplier(track: String, level: int) -> float:
	var values: Array = MULTIPLIERS.get(track, [1.0]) as Array
	return float(values[clampi(level, 0, values.size() - 1)])


static func next_cost(track: String, level: int) -> int:
	if not TRACKS.has(track) or level < 0 or level >= MAX_LEVEL:
		return 0
	return COSTS[clampi(level, 0, COSTS.size() - 1)]


static func format_multiplier(value: float) -> String:
	return "×" + String.num(value, 2)
