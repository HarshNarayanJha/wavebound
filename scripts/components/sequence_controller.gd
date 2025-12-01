class_name SequenceController extends Node

@export var player_spawner: PlayerSpawner
@export var time_data: TimeData
@export var tsunami_data: TsunamiData

@export var shelter_data: ShelterData
@export var inventory_data: InventoryData

@export var notification_data: NotificationData

@export_file var main_menu_path: String

@export_category("Inventory Items")
@export var building_mat: MaterialData
@export var energy_mat: MaterialData

# FLAGS
var welcome_notif_sent := false
var initial_task_given := false
var building_mat_notif_sent := false
var energy_mat_notif_sent := false

signal game_over

func _ready() -> void:
	# initial set of notifications
	player_spawner.player_spawned.connect(_handle_player_spawned)
	inventory_data.inventory_updated.connect(_handle_inventory_updated)
	inventory_data.energy_updated.connect(_handle_energy_updated)
	shelter_data.health_updated.connect(_handle_shelter_health_updated)

	time_data.day_time_changed.connect(_handle_day_time_changed)

func _handle_player_spawned(_player: Player) -> void:
	if not welcome_notif_sent:
		# show welcome
		await get_tree().create_timer(2).timeout
		notification_data.send_notification(DataData.STR_WELCOME_NOTIF, NotificationData.NotifType.INFO, 5)
		welcome_notif_sent = true

	if not initial_task_given:
		# set initial task
		await get_tree().create_timer(6).timeout
		notification_data.send_notification(DataData.STR_SHELTER_TASK, NotificationData.NotifType.TASK)

		# tell about the radio button
		await get_tree().create_timer(2).timeout
		notification_data.send_notification(DataData.STR_RADIO_BUTTON_NOTIF, NotificationData.NotifType.INFO, 7)

		initial_task_given = true

func _handle_inventory_updated() -> void:
	if not building_mat_notif_sent:
		if inventory_data.get_count(building_mat) >= 100:
			notification_data.send_notification(DataData.STR_INITIAL_BUILDING_MAT_NOTIF, NotificationData.NotifType.INFO, 8)
			building_mat_notif_sent = true

func _handle_day_time_changed(day_time: TimeData.DayTime, day: int) -> void:
	if day == 1 and day_time == TimeData.DayTime.NIGHT:
		if shelter_data.get_current_health() == 0:
			# first night and shelter not built yet
			print("GAME OVER")
			notification_data.send_notification(DataData.STR_SHELTER_UNBUILT_GAME_OVER_NOTIF, NotificationData.NotifType.INFO, 5)
			# TODO: Handle Game Over Sequence
			game_over.emit()
			await get_tree().create_timer(5).timeout
			_change_to_main_menu(Color.PALE_GREEN)
		else:
			# first night notification
			notification_data.send_notification(DataData.STR_NIGHT_BUTTON_NOTIF, NotificationData.NotifType.INFO, 5)

func _handle_energy_updated(_o: float, _n: float) -> void:
	if _o > 0 and _n == 0:
		print("GAME OVER")
		notification_data.send_notification(DataData.STR_ENERGY_GAME_OVER_NOTIF, NotificationData.NotifType.INFO, 5)
		# TODO: Handle Game Over Sequence
		game_over.emit()
		await get_tree().create_timer(5).timeout
		_change_to_main_menu(Color.SEA_GREEN)

func _handle_shelter_health_updated(_o: float, _n: float) -> void:
	if _o > 0 and _n == 0:
		print("GAME OVER")
		notification_data.send_notification(DataData.STR_SHELTER_GAME_OVER_NOTIF, NotificationData.NotifType.INFO, 5)
		# TODO: Handle Game Over Sequence
		game_over.emit()
		await get_tree().create_timer(5).timeout
		_change_to_main_menu(Color.INDIAN_RED)

func _change_to_main_menu(color: Color) -> void:
	SceneManager.change_scene(ResourceUID.uid_to_path(main_menu_path), {"color": color, "wait_time": 0.8, "speed": 1})

func _exit_tree() -> void:
	player_spawner.player_spawned.disconnect(_handle_player_spawned)
	inventory_data.inventory_updated.disconnect(_handle_inventory_updated)
	time_data.day_time_changed.disconnect(_handle_day_time_changed)
	inventory_data.energy_updated.disconnect(_handle_energy_updated)
	shelter_data.health_updated.disconnect(_handle_shelter_health_updated)
