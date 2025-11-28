class_name TsunamiData extends Resource

enum TsunamiLevel { NONE, LOW, MED, HIGH }

@export var tsunami_damage: Dictionary[TsunamiLevel, float]
@export var tsunami_level_text: Dictionary[TsunamiLevel, String]

var predictions: Array[TsunamiLevel] = []
var weights := PackedFloat32Array([1, 0.8, 0.5, 0.1])

signal wave_hit(level: TsunamiLevel)
signal predictions_updated(time_sec: float)

func get_next_prediction() -> TsunamiLevel:
	if predictions.is_empty():
		return TsunamiData.TsunamiLevel.NONE
	return predictions[0]

func get_next_prediction_text() -> String:
	if predictions.is_empty():
		return "Unknown"

	return tsunami_level_text[get_next_prediction()]
