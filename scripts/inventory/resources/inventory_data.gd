class_name InventoryData extends Resource

class ItemStack:
	const MAX_STACK = 9999

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


@export var max_energy := 100.0
@export var initial_energy := 0.0
@export var base_energy_cost := 10
@export var base_energy_recharge := 20.0

var _current_energy: float = -1

var items: Dictionary[String, ItemStack]

## signals
# item signals
signal item_added(old_stack: ItemStack, new_stack: ItemStack)
signal item_removed(old_stack: ItemStack, new_stack: ItemStack)
signal inventory_updated

# energy signals
signal energy_depleted(amount: float)
signal energy_restored(amount: float)
signal energy_updated(old_energy: float, new_energy: float)

func init() -> void:
	_current_energy = initial_energy
	energy_updated.emit(0, _current_energy)

func use_energy(amount: float) -> bool:
	if _current_energy - amount >= 0:
		_current_energy -= amount
		energy_depleted.emit(amount)
		energy_updated.emit(_current_energy + amount, _current_energy)
		return true

	return false

func recharge_energy(force := false, amount: float = base_energy_recharge) -> bool:
	if _current_energy + amount <= max_energy:
		_current_energy += amount
		energy_restored.emit(amount)
		energy_updated.emit(_current_energy - amount, _current_energy)
		return true

	if force:
		_current_energy = max_energy
		energy_restored.emit(amount)
		energy_updated.emit(_current_energy - amount, _current_energy)
		return true

	return false

func get_current_energy() -> float:
	return _current_energy

func get_energy_refill_cost() -> int:
	return base_energy_cost

func _add_item(item: MaterialData, qty: int = 1) -> bool:
	if items.has(item.name):
		var old = items.get(item.name)
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

func has_item(item: MaterialData) -> bool:
	return item.name in items

func get_count(item: MaterialData) -> int:
	if not has_item(item):
		return 0

	return items[item.name].count

func get_all_items() -> Array[ItemStack]:
	return items.values()
