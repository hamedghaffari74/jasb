class_name Art
extends RefCounted
## Unique vector art for factories and resources.

const FACTORIES: Dictionary = {
	"mine": preload("res://assets/sprites/factories/mine.svg"),
	"smelter": preload("res://assets/sprites/factories/smelter.svg"),
	"mill": preload("res://assets/sprites/factories/mill.svg"),
	"tool_shop": preload("res://assets/sprites/factories/tool_shop.svg"),
	"car_plant": preload("res://assets/sprites/factories/car_plant.svg"),
	"appliance_plant": preload("res://assets/sprites/factories/appliance_plant.svg"),
	"market": preload("res://assets/sprites/factories/market.svg"),
}

const PRODUCTS: Dictionary = {
	"ore": preload("res://assets/sprites/resources/ore.svg"),
	"iron": preload("res://assets/sprites/resources/iron.svg"),
	"steel": preload("res://assets/sprites/resources/steel.svg"),
	"tools": preload("res://assets/sprites/resources/tools.svg"),
	"cars": preload("res://assets/sprites/resources/cars.svg"),
	"appliances": preload("res://assets/sprites/resources/appliances.svg"),
}

const UI: Dictionary = {
	"star": preload("res://assets/sprites/ui/star.svg"),
	"global_price": preload("res://assets/sprites/ui/global_price.svg"),
	"global_speed": preload("res://assets/sprites/ui/global_speed.svg"),
	"global_capacity": preload("res://assets/sprites/ui/global_capacity.svg"),
}


static func factory(id: String) -> Texture2D:
	return FACTORIES.get(id, null) as Texture2D


static func product(id: String) -> Texture2D:
	return PRODUCTS.get(id, null) as Texture2D


static func ui(id: String) -> Texture2D:
	return UI.get(id, null) as Texture2D
