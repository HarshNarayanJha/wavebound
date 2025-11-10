class_name InventoryManager extends Node

@export var inventory: InventoryData

func add_one(item: MaterialData) -> bool:
	return inventory._add_item(item)

func add_many(item: MaterialData, qty: int) -> bool:
	return inventory._add_item(item, qty)

func remove_one(item: MaterialData) -> bool:
	return inventory._remove_item(item)

func remove_many(item: MaterialData, qty: int) -> bool:
	return inventory._remove_item(item, qty)

func has_item(item: MaterialData) -> bool:
	return inventory._has_item(item)

func get_count(item: MaterialData) -> int:
	return inventory._get_count(item)

func get_all_items() -> Array[InventoryData.ItemStack]:
	return inventory._get_all_items()
