extends PlayerBaseState

@export var inventory_data: InventoryData
@export var energy_cost: float = 0.05

func enter() -> void:
	inventory_data.register_energy_user(energy_cost)
	# to update the UI
	inventory_data.use_energy(0)

func exit() -> void:
	inventory_data.deregister_energy_user(energy_cost)
	# to update the UI
	inventory_data.use_energy(0)

func process(_delta: float) -> StringName:
	inventory_data.use_energy(energy_cost * _delta)

	return STATE_WALK

func physics_process(_delta: float) -> StringName:
	move(_delta)

	if input.input_dir.is_zero_approx() and player.velocity.length_squared() < 0.25:
		return STATE_IDLE

	return STATE_WALK

func handle_input(_event: InputEvent) -> StringName:
	return STATE_WALK
