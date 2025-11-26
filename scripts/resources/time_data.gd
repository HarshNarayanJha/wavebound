class_name TimeData extends Resource

enum DayTime {
	DAY,
	NIGHT
}

@export var start_day_time: DayTime
@export var start_day := 0

@export var max_days := 3
@export var day_time_minutes := 3.0
@export var night_time_minutes := 2.5

var second_duration: float

var current_time: float
var current_day: int
var current_day_time: DayTime

var day_duration: float
var night_duration: float
var full_day_duration: float

var is_active := true

signal day_time_changed(day_time: DayTime, day: int)
signal day_changed(day: int)
signal second_tick
signal last_day_completed

func init(s_duration: float):
	second_duration = s_duration

	# set current time
	if start_day_time == DayTime.DAY:
		current_time = 0
	elif start_day_time == DayTime.NIGHT:
		current_time = day_time_minutes
	else:
		assert(false, "Invalid start_day_time")

	current_day = start_day
	current_day_time = start_day_time

	day_duration = day_time_minutes * 60
	night_duration = night_time_minutes * 60
	full_day_duration = day_duration + night_duration

func tick_second():
	if not is_active:
		return

	# increment no. of minutes
	current_time += 1.0

	# if we cross the full day
	if current_time >= full_day_duration:
		current_time = 0
		current_day += 1
		if current_day >= max_days:
			# completed
			# current_day = 0
			last_day_completed.emit()
			is_active = false
			return
		else:
			# change back to day
			current_day_time = DayTime.DAY

			day_time_changed.emit(get_current_day_time(), get_current_day())
			day_changed.emit(get_current_day())

	elif current_time >= day_duration:
		current_day_time = DayTime.NIGHT
		day_time_changed.emit(get_current_day_time(), get_current_day())

	second_tick.emit()

func get_current_time():
	return current_time

func get_current_day():
	return current_day + 1

func get_current_day_time():
	return current_day_time

func get_second_duration():
	return second_duration
