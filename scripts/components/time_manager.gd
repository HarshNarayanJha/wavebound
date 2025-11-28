extends Node2D

@export var debug := false

@export var timer: Timer
@export var second_duration: float = 1.0
@export var debug_label: Label
@export var night_light: Light2D

@export var time_data: TimeData

func _ready() -> void:
	timer.timeout.connect(_tick)
	timer.one_shot = false
	timer.start(second_duration)

	time_data.init(second_duration)
	time_data.last_day_completed.connect(finish)


	if debug:
		debug_label.show()
		time_data.second_tick.connect(func(): debug_label.set_text(
			"Time: %f\nDay: %d\nType: %s\n" % [
				time_data.get_current_time(),
				time_data.get_current_day(),
				time_data.DayTime.keys()[time_data.get_current_day_time()]
			])
		)
	else:
		debug_label.queue_free()

	time_data.day_time_changed.connect(handle_day_time_change)
	handle_day_time_change(time_data.get_current_day_time(), time_data.get_current_day())

func _tick() -> void:
	time_data.tick_second()

func finish() -> void:
	timer.stop()
	timer.timeout.disconnect(_tick)

func handle_day_time_change(day_time: TimeData.DayTime, _day: int) -> void:
	if day_time == TimeData.DayTime.DAY:
		night_light.hide()
	else:
		night_light.show()

func _exit_tree() -> void:
	timer.timeout.disconnect(_tick)
	timer.stop()
