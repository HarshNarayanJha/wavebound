extends Control

@export_category("References")
@export var building_mat_label: Label
@export var food_label: Label

@export_category("Signals")
@export var inventory_data: InventoryData

@export_category("Item References")
@export var building_mat: MaterialData
@export var food_mat: MaterialData

func _ready() -> void:
	update_item_count()
	inventory_data.inventory_updated.connect(update_item_count)

func update_item_count() -> void:
	building_mat_label.set_text("x%d" % inventory_data.get_count(building_mat))
	food_label.set_text("x%d" % inventory_data.get_count(food_mat))

func _exit_tree() -> void:
	inventory_data.inventory_updated.disconnect(update_item_count)
