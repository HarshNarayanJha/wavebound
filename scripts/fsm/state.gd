class_name State extends Node

## Reference to the controlling object
var object: Node2D
var fsm: StateMachine

func _ready() -> void:
	pass

func enter() -> void:
	pass

func exit() -> void:
	pass

func process(_delta: float) -> StringName:
	return &""

func physics_process(_delta: float) -> StringName:
	return &""

func handle_input(_event: InputEvent) -> StringName:
	return &""
