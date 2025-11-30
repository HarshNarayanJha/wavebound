class_name SequenceController extends Node

@export var player_spawner: PlayerSpawner
@export var time_data: TimeData
@export var tsunami_data: TsunamiData

@export var shelter_data: ShelterData
@export var inventory_data: InventoryData

@export var notification_data: NotificationData

@export_category("Inventory Items")
@export var building_mat: MaterialData
@export var energy_mat: MaterialData

# FLAGS
var welcome_notif_sent := false
var initial_task_given := false
var building_mat_notif_sent := false
var energy_mat_notif_sent := false

func _ready() -> void:
	# initial set of notifications
	player_spawner.player_spawned.connect(_show_initial_notifications)
	inventory_data.inventory_updated.connect(_show_inventory_material_notification)

func _show_initial_notifications(_player: Player) -> void:
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

func _show_inventory_material_notification() -> void:
	if not building_mat_notif_sent:
		if inventory_data.get_count(building_mat) >= 100:
			notification_data.send_notification(DataData.STR_INITIAL_BUILDING_MAT_NOTIF, NotificationData.NotifType.INFO, 8)
			building_mat_notif_sent = true


func _exit_tree() -> void:
	player_spawner.player_spawned.disconnect(_show_initial_notifications)
	inventory_data.inventory_updated.disconnect(_show_inventory_material_notification)
