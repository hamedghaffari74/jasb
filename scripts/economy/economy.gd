class_name Economy
extends RefCounted
## Fixed sell prices and product colours for the sandbox.

const PRICES: Dictionary = {
	"ore": 3,
	"iron": 7,
	"steel": 15,
	"tools": 35,
	"cars": 160,
	"appliances": 70,
}

const COLORS: Dictionary = {
	"ore": Color("#d9a066"),
	"iron": Color("#ff8a2a"),
	"steel": Color("#20dfff"),
	"tools": Color("#25d366"),
	"cars": Color("#ff6b6b"),
	"appliances": Color("#b388ff"),
}

const ORDER: Array[String] = ["ore", "iron", "steel", "tools", "cars", "appliances"]


static func price(product: String) -> int:
	return int(PRICES.get(product, 0))


static func sell_price(product: String) -> int:
	return maxi(roundi(float(price(product)) * SaveManager.global_price()), 1)


static func is_sellable(product: String) -> bool:
	return PRICES.has(product)


static func color(product: String) -> Color:
	return COLORS.get(product, Palette.TEXT)


static func prices_line() -> String:
	var parts: PackedStringArray = []
	for product in ORDER:
		parts.append("%s $%d" % [I18n.product_name(product), sell_price(product)])
	return I18n.t("sell_prefix") + "  " + "   ".join(parts)
