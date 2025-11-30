extends Control

@export var debug := false

@export_category("References")
@export_subgroup("Shelter")
@export var building_mat_label: Label
@export var shelter_health_bar: ProgressBar
@export var repair_shelter_button: Button

@export_subgroup("Energy")
@export var energy_label: Label
@export var energy_cell_bar: ProgressBar
@export var replenish_energy_button: Button
@export var energy_use_mult_label: Label

@export_subgroup("Tsunami")
@export var tsunami_data: TsunamiData
@export var next_tsunami_label: Label
@export var tsunami_coutdown_progress: ProgressBar

@export_subgroup("Notification")
@export var notifications_list: Control
@export var notification_scene: PackedScene
@export var notification_data: NotificationData
@export var task_label: Label

@export_subgroup("Time")
@export var time_progress_dict: Dictionary[TimeData.DayTime, TextureProgressBar]
@export var day_counter: Label

@export_subgroup("Misc")
@export var crt_filter: TextureRect
@export var wrap_to_shelter_button: TextureButton

@export_category("Signals")
@export var inventory_data: InventoryData
@export var shelter_data: ShelterData
@export var time_data: TimeData
@export var player_data: PlayerData

@export_category("Item References")
@export var building_mat: MaterialData
@export var energy_mat: MaterialData

var tw: Tween

func _ready() -> void:
	update_item_count()
	update_shelter_healthbar(0, shelter_data.get_current_health())
	update_energy_bar(0, inventory_data.get_current_energy())
	update_shelter_repair_button()
	update_energy_replenish_button()
	update_wrap_to_shelter_button()
	update_next_tsunami_label()

	initialize_notifications()
	initialize_task()
	initialize_time_display()

	inventory_data.inventory_updated.connect(_inventory_updated)

	shelter_data.health_updated.connect(_shelter_health_updated)
	inventory_data.energy_updated.connect(_energy_updated)

	repair_shelter_button.pressed.connect(_try_repair_shelter)
	replenish_energy_button.pressed.connect(_try_replenish_energy)

	shelter_data.player_near_shelter.connect(update_shelter_repair_button)

	tsunami_data.predictions_updated.connect(_on_tsunami_updated)
	tsunami_coutdown_progress.value = 1.0

	notification_data.new_notification.connect(_on_new_notification)
	notification_data.set_task.connect(_on_set_task)

	time_data.second_tick.connect(_on_time_second_tick)
	time_data.day_time_changed.connect(_on_day_time_changed)
	time_data.day_changed.connect(_on_day_changed)

	crt_filter.show()

	wrap_to_shelter_button.pressed.connect(_wrap_to_shelter)

func _on_tsunami_updated(time_sec: float) -> void:
	update_next_tsunami_label()
	update_tsunami_timer(time_sec)

func _inventory_updated() -> void:
	update_item_count()
	update_shelter_repair_button()
	update_energy_replenish_button()
	update_wrap_to_shelter_button()

func _shelter_health_updated(o: float, n: float) -> void:
	update_shelter_healthbar(o, n)
	update_shelter_repair_button()

func _energy_updated(o: float, n: float) -> void:
	update_energy_bar(o, n)
	update_energy_replenish_button()
	update_wrap_to_shelter_button()

func _on_new_notification(notif: NotificationData.Notif) -> void:
	add_notification(notif)

func _on_set_task(task: NotificationData.Notif) -> void:
	update_task(task)

func update_next_tsunami_label() -> void:
	next_tsunami_label.set_text(tsunami_data.get_next_prediction_text())

func update_tsunami_timer(time_sec: float) -> void:
	if tw:
		tw.kill()
		tw = null

	tsunami_coutdown_progress.value = 1
	var tween = get_tree().create_tween()
	tween.tween_property(tsunami_coutdown_progress, "value", 0, time_sec)
	tw = tween

func update_item_count() -> void:
	building_mat_label.set_text("x%d" % inventory_data.get_count(building_mat))
	energy_label.set_text("x%d" % inventory_data.get_count(energy_mat))

func update_shelter_healthbar(_o: float, n: float)-> void:
	shelter_health_bar.value = n

func update_energy_bar(_o: float, n: float)-> void:
	energy_cell_bar.value = n
	energy_use_mult_label.set_text("x%.2f" % inventory_data.get_effective_energy_use())

func initialize_notifications() -> void:
	for c in notifications_list.get_children():
		notifications_list.remove_child(c)
		c.queue_free()

func initialize_task() -> void:
	task_label.set_text("No task assigned")

func initialize_time_display() -> void:
	time_progress_dict[TimeData.DayTime.DAY].value = 0
	time_progress_dict[TimeData.DayTime.NIGHT].value = 0
	day_counter.set_text(str(time_data.get_current_day()))

func _on_time_second_tick() -> void:
	if time_data.get_current_day_time() == TimeData.DayTime.DAY:
		# time_progress_dict[TimeData.DayTime.DAY].value = time_data.get_current_time() / time_data.day_duration
		get_tree().create_tween().tween_property(
			time_progress_dict[TimeData.DayTime.DAY],
			"value",
			time_data.get_current_time() / time_data.day_duration,
			time_data.get_second_duration()
		)
	elif time_data.get_current_day_time() == TimeData.DayTime.NIGHT:
		# time_progress_dict[TimeData.DayTime.NIGHT].value = (time_data.get_current_time() - time_data.day_duration) / time_data.night_duration
		get_tree().create_tween().tween_property(
			time_progress_dict[TimeData.DayTime.NIGHT],
			"value",
			(time_data.get_current_time() - time_data.day_duration) / time_data.night_duration,
			time_data.get_second_duration()
		)

func _on_day_time_changed(day_time: TimeData.DayTime) -> void:
	print("Day Time Changed to %d" % day_time)

func _on_day_changed(day: int) -> void:
	# time_progress_dict[TimeData.DayTime.DAY].value = 0
	# time_progress_dict[TimeData.DayTime.NIGHT].value = 0
	get_tree().create_tween().tween_property(
		time_progress_dict[TimeData.DayTime.DAY],
		"value",
		0,
		time_data.get_second_duration() / 3.0
	)
	get_tree().create_tween().tween_property(
		time_progress_dict[TimeData.DayTime.NIGHT],
		"value",
		0,
		time_data.get_second_duration() / 3.0
	)
	day_counter.set_text(str(day))

func add_notification(notif: NotificationData.Notif) -> void:
	var notiff: Control = notification_scene.instantiate()
	notifications_list.add_child(notiff)
	notiff.set_position(Vector2(0, 0))
	notiff.set_text(notif.text)
	notiff.set_timeout(notif.timeout)
	notiff.set_type(notif.type)
	notiff.display()

func update_task(task: NotificationData.Notif) -> void:
	task_label.set_text(task.text)

func update_shelter_repair_button() -> void:
	if debug: CLogger.d("GAME UI", "updating shelter repair button")

	var text = shelter_data.get_current_action_name()

	var is_full := shelter_data.get_current_health() == shelter_data.max_health
	var has_material := (inventory_data.get_count(building_mat) >= shelter_data.get_building_cost())

	if not shelter_data.is_player_near():
		repair_shelter_button.disabled = true
		repair_shelter_button.set_text("Away from shelter")
		return

	if is_full:
		repair_shelter_button.disabled = true
		repair_shelter_button.set_text(text)
		return

	text += " x" + str(shelter_data.get_building_cost())

	# can repair
	if has_material:
		repair_shelter_button.disabled = false
		repair_shelter_button.set_text(text)
		return

	# cannot build
	repair_shelter_button.disabled = true
	repair_shelter_button.set_text(text)

func update_energy_replenish_button() -> void:
	var text = "Replenish"

	var is_full := inventory_data.get_current_energy() == inventory_data.max_energy
	var has_material := (inventory_data.get_count(energy_mat) >= inventory_data.get_energy_refill_cost())

	if is_full:
		replenish_energy_button.disabled = true
		replenish_energy_button.set_text(text)
		return

	text += " x" + str(inventory_data.get_energy_refill_cost())

	# can replenish
	if has_material:
		replenish_energy_button.disabled = false
		replenish_energy_button.set_text(text)
		return

	# cannot replenish
	replenish_energy_button.disabled = true
	replenish_energy_button.set_text(text)

func update_wrap_to_shelter_button() -> void:
	if shelter_data.is_player_near():
		# cannot wrap
		wrap_to_shelter_button.disabled = true
		return

	var has_material := (inventory_data.get_count(energy_mat) >= 500)

	if has_material:
		wrap_to_shelter_button.disabled = false
		return

	# cannot wrap
	wrap_to_shelter_button.disabled = true

func _try_replenish_energy() -> bool:
	var cost := inventory_data.get_energy_refill_cost()
	if inventory_data._remove_item(energy_mat, cost):
		if inventory_data.recharge_energy(true):
			return true

		# add back if can't refill
		inventory_data._add_item(energy_mat, cost)
		return false

	return false

func _try_repair_shelter() -> bool:
	var cost := shelter_data.get_building_cost()
	if inventory_data._remove_item(building_mat, cost):
		if shelter_data.repair_damage(true):
			return true

		# add back if can't repair
		inventory_data._add_item(building_mat, cost)
		return false

	return false

func _wrap_to_shelter() -> void:
	if shelter_data.is_player_near():
		return

	if inventory_data._remove_item(energy_mat, 500):
		if player_data.to_shelter():
			return

		# add back if can't wrap
		inventory_data._add_item(energy_mat, 500)

func _exit_tree() -> void:
	inventory_data.inventory_updated.disconnect(_inventory_updated)

	shelter_data.health_updated.disconnect(_shelter_health_updated)
	inventory_data.energy_updated.disconnect(_energy_updated)

	repair_shelter_button.pressed.disconnect(_try_repair_shelter)
	replenish_energy_button.pressed.disconnect(_try_replenish_energy)

	shelter_data.player_near_shelter.disconnect(update_shelter_repair_button)

	tsunami_data.predictions_updated.disconnect(_on_tsunami_updated)

	notification_data.new_notification.disconnect(_on_new_notification)
	notification_data.set_task.disconnect(_on_set_task)

	time_data.second_tick.disconnect(_on_time_second_tick)
	time_data.day_time_changed.disconnect(_on_day_time_changed)
	time_data.day_changed.disconnect(_on_day_changed)

	wrap_to_shelter_button.pressed.disconnect(_wrap_to_shelter)
