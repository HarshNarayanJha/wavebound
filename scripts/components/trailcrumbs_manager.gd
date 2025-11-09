class_name TrailcrumbsManager extends Node2D

@export var debug := false

@export_category("Trailcrumb Settings")
@export var crumb_scene: PackedScene
@export var time_gap := 2.0
@export var while_moving_only := true
@export var crumb_offset := 1.0

@export_category("References")
@export var crumb_parent: Node
@export var drop_timer: Timer
@export var player: Player

const TAG := "Trailcrumbs Manager"

func _ready() -> void:
	if not crumb_scene or not player or not drop_timer or not crumb_parent:
		push_error("Some of the references are not assigned properly")
		return

	crumb_parent.get_parent().remove_child(crumb_parent)
	get_tree().current_scene.add_child(crumb_parent)

	drop_timer.wait_time = time_gap
	drop_timer.one_shot = false
	drop_timer.start()

	drop_timer.timeout.connect(drop_crumb)

func _exit_tree() -> void:
	drop_timer.timeout.disconnect(drop_crumb)

func drop_crumb() -> void:
	if player.state_machine.current_state != PlayerBaseState.STATE_WALK:
		if debug: CLogger.d(TAG, "Player is not moving, not dropping crumb")
		return

	var crumb = crumb_scene.instantiate()
	crumb_parent.add_child(crumb)
	var dir := -player.input.input_dir
	crumb.global_position = player.global_position + dir * crumb_offset

	if debug: CLogger.d(TAG, "Dropping trail crumb at " + str(crumb.global_position))
