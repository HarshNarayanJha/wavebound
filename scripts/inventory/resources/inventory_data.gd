class_name InventoryData extends Resource

class ItemStack:
	const MAX_STACK = 999

	var item: MaterialData
	var count: int = 0

	func _init(_item: MaterialData, _count: int) -> void:
		if _count > MAX_STACK:
			push_error("Only %d max items are supported" % MAX_STACK)
			return

		item = _item
		count = _count

	func inc(qty: int = 1) -> bool:
		if count + qty <= MAX_STACK:
			count += qty
			return true

		return false

	func dec(qty: int = 1) -> bool:
		if count - qty >= 0:
			count -= qty
			return true

		return false

var items: Dictionary[String, ItemStack]

# signals

signal item_added(old_stack: ItemStack, new_stack: ItemStack)
signal item_removed(old_stack: ItemStack, new_stack: ItemStack)
signal inventory_updated

func _add_item(item: MaterialData, qty: int = 1) -> bool:
	if items[item.name]:
		var old = items[item.name]
		if items[item.name].inc(qty):
			item_added.emit(old, items[item.name])
			inventory_updated.emit()
			return true

		return false

	else:
		var stk := ItemStack.new(item, qty)
		if stk:
			items[item.name] = stk
			item_added.emit(null, stk)
			inventory_updated.emit()
			return true

		return false

func _remove_item(item: MaterialData, qty: int = 1) -> bool:
	if items[item.name]:
		var old = items[item.name]
		if items[item.name].dec(qty):
			item_removed.emit(old, items[item.name])
			inventory_updated.emit()
			return true

		return false

	else:
		return false

func _has_item(item: MaterialData) -> bool:
	return item.name in items

func _get_count(item: MaterialData) -> int:
	if not _has_item(item):
		return 0

	return items[item.name].count

func _get_all_items() -> Array[ItemStack]:
	return items.values()
