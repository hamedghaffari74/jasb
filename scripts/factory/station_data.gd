class_name StationData
extends Resource
## Static tuning for one building. Edit the .tres files, not the code.

const BASE_BUFFER: int = 8

@export var id: String = ""
@export var display_name: String = ""
@export var input_item: String = ""
@export var input_amount: int = 0
@export var output_item: String = ""
@export var base_cycle: float = 1.0
@export var buy_cost: int = 0
@export var trait_cost: int = 20
@export var is_market: bool = false
@export var color: Color = Color.WHITE


func cycle_time() -> float:
	return maxf(base_cycle, 0.05)


func buffer_cap() -> int:
	return BASE_BUFFER
