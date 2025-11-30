class_name RadioController extends Node


@export_flags_2d_render var radio_layer: int

@export var radio_energy_use: float = 0.04
@export var night_vision_energy_use: float = 0.25

@export var radio_button: TextureButton
@export var night_vision_button: TextureButton

@export var inventory_data: InventoryData
@export var time_data: TimeData
@export var notification_data: NotificationData
@export var player_data: PlayerData

var radio_index := 0
var using_radio_energy := false

var using_night_vision_energy := false


func _ready() -> void:
	if radio_layer == 0:
		assert(false, "Please set a radio layer")

	while radio_index < 32:
		if radio_layer & (1 << radio_index) != 0:
			break
		radio_index += 1

	radio_button.toggled.connect(handle_radio_button_toggled)
	handle_radio_button_toggled(radio_button.button_pressed)

	night_vision_button.toggled.connect(handle_night_vision_button_toggled)
	handle_night_vision_button_toggled(night_vision_button.button_pressed)

	time_data.day_time_changed.connect(handle_day_time_changed)

func _exit_tree() -> void:
	radio_button.toggled.disconnect(handle_radio_button_toggled)
	night_vision_button.toggled.disconnect(handle_night_vision_button_toggled)
	time_data.day_time_changed.disconnect(handle_day_time_changed)

func handle_radio_button_toggled(state: bool) -> void:
	if state:
		inventory_data.register_energy_user(radio_energy_use)
		using_radio_energy = true
		get_viewport().set_canvas_cull_mask_bit(radio_index, 1)
	else:
		inventory_data.deregister_energy_user(radio_energy_use)
		using_radio_energy = false
		get_viewport().set_canvas_cull_mask_bit(radio_index, 0)

func handle_night_vision_button_toggled(state: bool) -> void:
	if state:
		if time_data.get_current_day_time() == TimeData.DayTime.NIGHT:
			inventory_data.register_energy_user(night_vision_energy_use)
			using_night_vision_energy = true
			player_data.toggle_trailcrumbs_light.emit(true)
		else:
			notification_data.send_notification(DataData.STR_NO_USE_NIGHTLIGHT_DAY_NOTIF, NotificationData.NotifType.INFO, 3)
			night_vision_button.set_pressed_no_signal(false)
	else:
		inventory_data.deregister_energy_user(night_vision_energy_use)
		using_night_vision_energy = false
		player_data.toggle_trailcrumbs_light.emit(false)

func _process(delta: float) -> void:
	if using_radio_energy:
		inventory_data.use_energy(radio_energy_use * delta)

	if using_night_vision_energy:
		inventory_data.use_energy(night_vision_energy_use * delta)

func handle_day_time_changed(day_time: TimeData.DayTime) -> void:
	if day_time == TimeData.DayTime.DAY:
		handle_night_vision_button_toggled(false)
