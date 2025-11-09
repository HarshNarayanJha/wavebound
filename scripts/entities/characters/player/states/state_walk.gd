extends PlayerBaseState

func enter() -> void:
	pass

func exit() -> void:
	pass

func process(_delta: float) -> StringName:
	#if input.scan_pressed:
		#return STATE_SPRINT

	return STATE_WALK

func physics_process(_delta: float) -> StringName:
	move(_delta)

	if input.input_dir.is_zero_approx() and player.velocity.length_squared() < 0.25:
		return STATE_IDLE

	return STATE_WALK

func handle_input(_event: InputEvent) -> StringName:
	return STATE_WALK
