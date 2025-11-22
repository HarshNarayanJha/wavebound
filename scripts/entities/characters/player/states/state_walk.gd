extends PlayerBaseState

@export var inventory_data: InventoryData
@export var energy_cost: float = 0.05

func enter() -> void:
	pass

func exit() -> void:
	pass

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
