class_name StateMachine extends Node

@export var debug := false

## The intial state of this state machine
@export var initial_state: StringName

## Dictionary of all states in the state machine
@export var states: Dictionary[StringName, State] = {}

## The last state of the state machine
var previous_state: StringName

## Current state of the state machine
var current_state: StringName

signal transitioning(old_state: StringName, new_state: StringName)

@export var sm_name: String
@onready var TAG: String = "State Machine (%s)" % sm_name

func _ready() -> void:
	set_process_mode(PROCESS_MODE_DISABLED)

func _process(delta: float) -> void:
	if not current_state:
		return

	change_state(states[current_state].process(delta))

func _physics_process(delta: float) -> void:
	if not current_state:
		return

	change_state(states[current_state].physics_process(delta))

func _unhandled_input(event: InputEvent) -> void:
	if not current_state:
		return

	change_state(states[current_state].handle_input(event))

## Initialize the state machine with player instance
func init(player: Player) -> void:
	for s in states.values():
		var st = s as State
		st.object = player
		st.fsm = self

	if debug: CLogger.d(TAG, "INIT: %s" % str(states.keys()))

	if states and initial_state:
		change_state(initial_state)
		set_process_mode(PROCESS_MODE_INHERIT)
	else:
		if debug: CLogger.e(TAG, "State Machine is empty")


func change_state(new_state: StringName) -> void:
	if not new_state || new_state == current_state:
		return

	if debug: CLogger.d(TAG, "Changing state %s -> %s" % [current_state, new_state])

	if current_state:
		states[current_state].exit()

	transitioning.emit(current_state, new_state)

	previous_state = current_state
	current_state = new_state

	states[current_state].enter()
