extends PlayerBaseState

func enter() -> void:
	pass

func exit() -> void:
	pass

func process(_delta: float) -> StringName:
	return STATE_SCAN

func physics_process(_delta: float) -> StringName:
	move(_delta)
	return STATE_SCAN

func handle_input(_event: InputEvent) -> StringName:
	return STATE_SCAN
