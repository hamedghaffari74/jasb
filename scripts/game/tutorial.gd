class_name Tutorial
extends RefCounted
## Short guidance that follows the player's progression.


static func tip(stations: Dictionary, links: Array[Link], money: int) -> String:
	if SaveManager.can_prestige():
		return I18n.t("tip_prestige")
	var has_any: bool = not links.is_empty()
	if not has_any:
		var mine: Station = stations.get("mine") as Station
		if mine != null and mine.working:
			return I18n.t("tip_wait_mine")
		if mine != null and mine.output_count == 0 and not mine.is_auto():
			return I18n.t("tip_tap_mine")
		return I18n.t("tip_drag_ore")
	if not SaveManager.is_unlocked("smelter"):
		var smelter_cost: int = _cost(stations, "smelter")
		if money >= smelter_cost:
			return I18n.t("tip_buy_smelter") % smelter_cost
		return I18n.t("tip_keep_ore")
	if not _has_link(links, "mine", "smelter"):
		return I18n.t("tip_mine_smelter")
	var smelter: Station = stations.get("smelter") as Station
	if smelter != null and not smelter.is_auto() and smelter.output_count == 0 and smelter.input_count >= smelter.data.input_amount:
		return I18n.t("tip_tap_smelter")
	if not _has_outgoing(links, "smelter"):
		return I18n.t("tip_sell_iron")
	if not SaveManager.is_unlocked("mill"):
		var mill_cost: int = _cost(stations, "mill")
		if money >= mill_cost:
			return I18n.t("tip_buy_mill") % mill_cost
		return I18n.t("tip_afford_mill")
	if not _has_link(links, "smelter", "mill"):
		return I18n.t("tip_smelter_mill")
	if not _has_outgoing(links, "mill"):
		return I18n.t("tip_mill_out")
	if not SaveManager.is_unlocked("tool_shop"):
		var tool_cost: int = _cost(stations, "tool_shop")
		if money >= tool_cost:
			return I18n.t("tip_buy_tool") % tool_cost
		return I18n.t("tip_afford_tool")
	if not _has_link(links, "mill", "tool_shop"):
		return I18n.t("tip_mill_tool")
	if not _has_outgoing(links, "tool_shop"):
		return I18n.t("tip_tool_out")
	if not SaveManager.is_unlocked("appliance_plant"):
		return I18n.t("tip_buy_more")
	return I18n.t("tip_final")


static func _has_link(links: Array[Link], from_id: String, to_id: String) -> bool:
	for link in links:
		if link.from != null and link.to != null:
			if link.from.data.id == from_id and link.to.data.id == to_id:
				return true
	return false


static func _has_outgoing(links: Array[Link], id: String) -> bool:
	for link in links:
		if link.from != null and link.from.data.id == id:
			return true
	return false


static func _cost(stations: Dictionary, id: String) -> int:
	var station: Station = stations.get(id) as Station
	return station.data.buy_cost if station != null and station.data != null else 0
