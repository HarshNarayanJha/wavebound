class_name ShelterData extends Resource

enum ShelterState {
	UNCONSTRUCTED,
	QUARTERS,
	HALF,
	THREE_QUARTERS,
	FULL
}

@export var initial_state := ShelterState.UNCONSTRUCTED
@export var sprites: Dictionary[ShelterState, Texture2D] = {}
@export var action_names: Dictionary[ShelterState, String] = {}
@export var max_health := 100
@export var initial_health := 0

# signals
signal damaged(amount: int)
signal repaired(amount: int)
signal health_updated(old_health: int, new_health: int)

var _current_sprite: Texture2D
var _current_state: ShelterState
var _current_health: int = -1:
	get:
		return _current_health
	set(value):
		var clamped_val := clampi(value, 0, max_health)
		if _current_health == clamped_val:
			return

		health_updated.emit(_current_health, clamped_val)
		_current_health = clamped_val

		if _current_health >= max_health * 0.75:
			_current_state = ShelterState.FULL
		elif _current_health >= max_health * 0.5:
			_current_state = ShelterState.THREE_QUARTERS
		elif _current_health >= max_health * 0.25:
			_current_state = ShelterState.HALF
		elif _current_health > 0:
			_current_state = ShelterState.QUARTERS
		elif _current_health == 0:
			_current_state = ShelterState.UNCONSTRUCTED
		else:
			_current_state = ShelterState.UNCONSTRUCTED

		_current_sprite = sprites[_current_state]
		CLogger.l("HELLO", str(sprites))

func init() -> void:
	_current_health = initial_health

func apply_damage(amount: int) -> int:
	damaged.emit(amount)
	_current_health -= amount

	return _current_health

func repair_damage(amount: int) -> int:
	repaired.emit(amount)
	_current_health += amount

	return _current_health

func get_current_health() -> int:
	return _current_health

func get_current_state() -> ShelterState:
	return _current_state

func get_current_sprite() -> Texture2D:
	return _current_sprite

func get_current_action_name() -> String:
	return action_names[_current_state]
