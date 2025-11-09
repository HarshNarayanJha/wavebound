class_name InputHandler extends Node

@export var debug := false

var input_dir := Vector2.ZERO

const TAG := "Input Handler"

func update() -> void:
	input_dir = Input.get_vector(&"left", &"right", &"up", &"down")

	if debug:
		CLogger.d(TAG, "Input Dir: %s" % str(input_dir))
