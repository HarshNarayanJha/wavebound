extends Control

@export_category("References")
@export var building_mat_label: Label
@export var food_label: Label
@export var shelter_health_bar: ProgressBar
@export var crt_filter: TextureRect

@export_category("Signals")
@export var inventory_data: InventoryData
@export var shelter_data: ShelterData

@export_category("Item References")
@export var building_mat: MaterialData
@export var food_mat: MaterialData

func _ready() -> void:
	update_item_count()
	update_shelter_healthbar(0, shelter_data.get_current_health())
	inventory_data.inventory_updated.connect(update_item_count)
	shelter_data.health_updated.connect(update_shelter_healthbar)
	crt_filter.show()

func update_item_count() -> void:
	building_mat_label.set_text("x%d" % inventory_data.get_count(building_mat))
	food_label.set_text("x%d" % inventory_data.get_count(food_mat))

func update_shelter_healthbar(o: float, n: float)-> void:
	shelter_health_bar.value = n


func _exit_tree() -> void:
	inventory_data.inventory_updated.disconnect(update_item_count)
	shelter_data.health_updated.disconnect(update_shelter_healthbar)
