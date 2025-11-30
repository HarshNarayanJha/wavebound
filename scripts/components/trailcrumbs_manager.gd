class_name TrailcrumbsManager extends Node2D

@export var debug := false

@export_category("Trailcrumb Settings")
@export var crumb_scene: PackedScene
@export var time_gap := 2.0
@export var crumb_offset := 1.0

@export_category("References")
@export var crumb_parent: Node
@export var drop_timer: Timer
@export var player: Player
@export var time_data: TimeData

const TAG := "Trailcrumbs Manager"

var can_drop := true

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
	time_data.day_time_changed.connect(_on_day_time_changed)

	player.player_data.toggle_trailcrumbs_light.connect(handle_toggle_trailcrumbs_light)
	handle_toggle_trailcrumbs_light(false)

func _exit_tree() -> void:
	drop_timer.timeout.disconnect(drop_crumb)
	time_data.day_time_changed.disconnect(_on_day_time_changed)
	player.player_data.toggle_trailcrumbs_light.disconnect(handle_toggle_trailcrumbs_light)

func drop_crumb() -> void:
	if not can_drop:
		return

	if player.state_machine.current_state != PlayerBaseState.STATE_WALK:
		if debug: CLogger.d(TAG, "Player is not moving, not dropping crumb")
		return

	var crumb: Node2D = crumb_scene.instantiate()
	var dir := -player.input.input_dir
	crumb.global_position = player.global_position + dir * crumb_offset
	crumb.rotate(dir.angle())
	crumb_parent.add_child(crumb)

	if debug: CLogger.d(TAG, "Dropping trail crumb at " + str(crumb.global_position))

func _on_day_time_changed(day_time: TimeData.DayTime, _day: int) -> void:
	if day_time == TimeData.DayTime.DAY:
		for c in crumb_parent.get_children():
			crumb_parent.remove_child(c)
			c.queue_free()
		can_drop = true
	elif day_time == TimeData.DayTime.NIGHT:
		can_drop = false

func handle_toggle_trailcrumbs_light(toggle: bool) -> void:
	for c in crumb_parent.get_children():
		var light: Light2D = c.get_child(0)
		light.enabled = toggle
