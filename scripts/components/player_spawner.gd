extends Node

@export var player_scene: PackedScene
@export var spawn_position: Marker2D
@export var main_camera: PhantomCamera2D
@export var spawn_at_ready := true
@export var notifcation_data: NotificationData

signal player_spawned(player: Player)

func _ready() -> void:
	if not spawn_at_ready:
		return

	spawn_player()

func spawn_player() -> void:
	if not player_scene:
		push_error("Player Scene is null in PlayerSpawner")
		return

	var spawn: Player = player_scene.instantiate()
	self.get_parent().add_child.call_deferred(spawn)
	spawn.global_position =spawn_position.global_position
	spawn.camera = main_camera
	main_camera.follow_target = spawn

	player_spawned.emit(spawn)

	await get_tree().create_timer(2).timeout
	notifcation_data.send_notification("Welcome to the 3-day island challenge!", NotificationData.NotifType.INFO)

	await get_tree().create_timer(5).timeout
	notifcation_data.send_notification("Collect materials on the island and build a shelter before nightfall", NotificationData.NotifType.TASK)
