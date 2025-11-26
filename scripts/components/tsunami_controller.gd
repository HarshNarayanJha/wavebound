class_name TsunamiController extends Node

@export var debug := false

@export var tsunami_data: TsunamiData
@export var tsunami_timer: Timer
@export var prediction_count: int = 20
@export var prediction_interval: float = 1.0
@export var prediction_interval_offset: float = 2
@export var prediction_error: float = 0.1
@export var start_already := false
@export var time_data: TimeData

var rng = RandomNumberGenerator.new()

const TAG := "TsunamiController"

func _ready() -> void:
	if start_already:
		begin_cycles()
	else:
		time_data.day_time_changed.connect(begin_cycles)

func begin_cycles(day_time: TimeData.DayTime = TimeData.DayTime.DAY, day: int = 0) -> void:
	if day_time == TimeData.DayTime.NIGHT and day == 1:
		generate_predictions()
		setup_wave_timer()
		# prevent from hitting again
		time_data.day_time_changed.disconnect(begin_cycles)
	else:
		push_error("CANNOT START wave cycles at this point")

func generate_predictions() -> void:
	# tsunami_data.predictions.clear()
	randomize()

	if debug: CLogger.d(TAG, "Generating predictions")

	var to_make := prediction_count - tsunami_data.predictions.size()
	for i in range(to_make):
		var level = TsunamiData.TsunamiLevel.values()[rng.rand_weighted(tsunami_data.weights)]
		tsunami_data.predictions.append(level)

	# emitted in setup_wave_timer now with time_sec
	# tsunami_data.predictions_updated.emit()
	if debug: CLogger.d(TAG, str(tsunami_data.predictions))

func setup_wave_timer() -> void:
	if not tsunami_data.predictions:
		return

	if debug: CLogger.d(TAG, "Setting up wave timer")

	var level := tsunami_data.predictions[0]
	if randf() < prediction_error:
		level = TsunamiData.TsunamiLevel.values()[rng.rand_weighted(tsunami_data.weights)]
		if debug: CLogger.d(TAG, "Error introduced in prediction")

	var time_sec := prediction_interval + randf_range(-prediction_interval_offset, prediction_interval_offset)

	# for c in tsunami_timer.timeout.get_connections():
	# 	print(c)
	# 	tsunami_timer.timeout.disconnect(c['callable'])

	tsunami_timer.timeout.connect(_on_wave_hit.bind(level))
	tsunami_timer.start(time_sec)

	tsunami_data.predictions_updated.emit(time_sec)

	# get_tree().create_timer(time_sec).timeout.connect(_on_wave_hit.bindv([level]))

	if debug: CLogger.d(TAG, "Wave timer set up for %d seconds" % time_sec)

func _on_wave_hit(level: TsunamiData.TsunamiLevel) -> void:
	if debug: CLogger.d(TAG, "Wave hit detected: %s" % str(level))
	tsunami_data.wave_hit.emit(level)
	tsunami_data.predictions.pop_front()

	generate_predictions()
	setup_wave_timer()

func get_next_prediction() -> TsunamiData.TsunamiLevel:
	return tsunami_data.get_next_prediction()

func get_all_predictions() -> Array[TsunamiData.TsunamiLevel]:
	return tsunami_data.predictions.duplicate()

func _exit_tree() -> void:
	time_data.day_time_changed.disconnect(begin_cycles)
