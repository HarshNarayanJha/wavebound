extends Control

@export_category("References")
@export_subgroup("Shelter")
@export var building_mat_label: Label
@export var shelter_health_bar: ProgressBar
@export var repair_shelter_button: Button

@export_subgroup("Energy")
@export var energy_label: Label
@export var energy_cell_bar: ProgressBar
@export var replenish_energy_button: Button

@export_subgroup("Misc")
@export var crt_filter: TextureRect

@export_category("Signals")
@export var inventory_data: InventoryData
@export var shelter_data: ShelterData

@export_category("Item References")
@export var building_mat: MaterialData
@export var energy_mat: MaterialData

func _ready() -> void:
	update_item_count()
	update_shelter_healthbar(0, shelter_data.get_current_health())
	update_energy_bar(0, inventory_data.get_current_energy())
	update_shelter_repair_button()
	update_energy_replenish_button()

	inventory_data.inventory_updated.connect(_inventory_updated)

	shelter_data.health_updated.connect(_shelter_health_updated)
	inventory_data.energy_updated.connect(_energy_updated)

	repair_shelter_button.pressed.connect(_try_repair_shelter)
	replenish_energy_button.pressed.connect(_try_replenish_energy)

	shelter_data.player_near_shelter.connect(update_shelter_repair_button)

	crt_filter.show()

func _inventory_updated() -> void:
	update_item_count()
	update_shelter_repair_button()
	update_energy_replenish_button()

func _shelter_health_updated(o: float, n: float) -> void:
	update_shelter_healthbar(o, n)
	update_shelter_repair_button()

func _energy_updated(o: float, n: float) -> void:
	update_energy_bar(o, n)
	update_energy_replenish_button()

func update_item_count() -> void:
	building_mat_label.set_text("x%d" % inventory_data.get_count(building_mat))
	energy_label.set_text("x%d" % inventory_data.get_count(energy_mat))

func update_shelter_healthbar(_o: float, n: float)-> void:
	shelter_health_bar.value = n

func update_energy_bar(_o: float, n: float)-> void:
	energy_cell_bar.value = n

func update_shelter_repair_button() -> void:
	CLogger.d("GAME UI", "updating shelter repair button")

	var text = shelter_data.get_current_action_name()

	var is_full := shelter_data.get_current_health() == shelter_data.max_health
	var has_material := (inventory_data.get_count(building_mat) >= shelter_data.get_building_cost())

	if not shelter_data.is_player_near():
		repair_shelter_button.disabled = true
		repair_shelter_button.set_text("Away from shelter")
		return

	if is_full:
		repair_shelter_button.disabled = true
		repair_shelter_button.set_text(text)
		return

	text += " x" + str(shelter_data.get_building_cost())

	# can repair
	if has_material:
		repair_shelter_button.disabled = false
		repair_shelter_button.set_text(text)
		return

	# cannot build
	repair_shelter_button.disabled = true
	repair_shelter_button.set_text(text)

func update_energy_replenish_button() -> void:
	var text = "Replenish"

	var is_full := inventory_data.get_current_energy() == inventory_data.max_energy
	var has_material := (inventory_data.get_count(energy_mat) >= inventory_data.get_energy_refill_cost())

	if is_full:
		replenish_energy_button.disabled = true
		replenish_energy_button.set_text(text)
		return

	text += " x" + str(inventory_data.get_energy_refill_cost())

	# can replenish
	if has_material:
		replenish_energy_button.disabled = false
		replenish_energy_button.set_text(text)
		return

	# cannot replenish
	replenish_energy_button.disabled = true
	replenish_energy_button.set_text(text)

func _try_replenish_energy() -> void:
	print("Trying to replenish energy")

func _try_repair_shelter() -> bool:
	var cost := shelter_data.get_building_cost()
	if inventory_data._remove_item(building_mat, cost):
		if shelter_data.repair_damage(true):
			return true

		# add back if can't repair
		inventory_data._add_item(building_mat, cost)
		return false

	return false

func _exit_tree() -> void:
	inventory_data.inventory_updated.disconnect(_inventory_updated)

	shelter_data.health_updated.disconnect(_shelter_health_updated)
	inventory_data.energy_updated.disconnect(_energy_updated)

	repair_shelter_button.pressed.disconnect(_try_repair_shelter)
	replenish_energy_button.pressed.disconnect(_try_replenish_energy)

	shelter_data.player_near_shelter.disconnect(update_shelter_repair_button)
