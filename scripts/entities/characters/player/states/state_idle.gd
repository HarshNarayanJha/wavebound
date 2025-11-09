extends PlayerBaseState

func enter() -> void:
	pass

func exit() -> void:
	pass

func process(_delta: float) -> StringName:
	if not input.input_dir.is_zero_approx():
		return STATE_WALK

	return STATE_IDLE

func physics_process(_delta: float) -> StringName:
	move(_delta)
	return STATE_IDLE

func handle_input(_event: InputEvent) -> StringName:
	return STATE_IDLE
