class_name PlayerData extends Resource

@export var speed: float
@export var acceleration: float
@export var deceleration: float

signal toggle_trailcrumbs_light(state: bool)
signal wrap_to_shelter

func to_shelter() -> bool:
	wrap_to_shelter.emit()
	return true
