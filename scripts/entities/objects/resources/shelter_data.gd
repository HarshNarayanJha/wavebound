class_name ShelterData extends Resource

enum ShelterState {
	UNCONSTRUCTED,
	QUARTERS,
	HALF,
	FULL,
	DEMOLISHED
}

@export var initial_state := ShelterState.UNCONSTRUCTED
@export var sprites: Dictionary[ShelterState, Texture2D] = {}
@export var action_names: Dictionary[ShelterState, String] = {}
@export var max_health := 100
@export var initial_health := 0
@export var base_building_price := 50
@export var base_repair_price := 50
@export var base_repair_amount := 20

# signals
signal damaged(amount: int)
signal repaired(amount: int)
signal health_updated(old_health: int, new_health: int)

signal player_near_shelter

var _is_player_near := false

var _current_sprite: Texture2D
var _current_state: ShelterState
var _current_health: int = -1:
	get:
		return _current_health
	set(value):
		var clamped_val := clampi(value, 0, max_health)
		if _current_health == clamped_val:
			return

		var _old_health = _current_health
		_current_health = clamped_val

		if _current_health >= max_health * 0.75:
			_current_state = ShelterState.FULL
		elif _current_health >= max_health * 0.5:
			_current_state = ShelterState.HALF
		elif _current_health >= max_health * 0.25:
			_current_state = ShelterState.QUARTERS
		elif _current_health == 0:
			_current_state = ShelterState.DEMOLISHED
		elif _current_health == -1:
			_current_state = ShelterState.UNCONSTRUCTED
		else:
			_current_state = ShelterState.UNCONSTRUCTED

		_current_sprite = sprites[_current_state]
		health_updated.emit(_old_health, _current_health)

func init() -> void:
	_current_health = initial_health
	_current_state = initial_state
	_current_sprite = sprites[_current_state]
	health_updated.emit(0, _current_health)

func player_at_shelter():
	CLogger.d("SHELTER DATA", "Player is near shelter")
	_is_player_near = true
	player_near_shelter.emit()

func player_left_shelter():
	CLogger.d("SHELTER DATA", "Player left shelter")
	_is_player_near = false
	player_near_shelter.emit()

func is_player_near():
	return _is_player_near

func apply_damage(amount: int) -> bool:
	if _current_health - amount >= 0:
		_current_health -= amount
		damaged.emit(amount)
		return true

	return false

func repair_damage(force: bool = false, amount: int = base_repair_amount) -> bool:
	if _current_health + amount <= max_health:
		_current_health += amount
		repaired.emit(amount)
		return true

	if force:
		var old_health = _current_health
		_current_health = max_health
		repaired.emit(old_health - _current_health)
		return true

	return false

func get_current_health() -> int:
	return _current_health

func get_current_state() -> ShelterState:
	return _current_state

func get_current_sprite() -> Texture2D:
	return _current_sprite

func get_current_action_name() -> String:
	return action_names[_current_state]

func get_building_cost() -> int:
	if _current_state == ShelterState.UNCONSTRUCTED:
		return base_building_price

	return base_repair_price
