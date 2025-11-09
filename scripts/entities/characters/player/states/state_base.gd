class_name PlayerBaseState extends State

var player: Player:
	get: return object

var input: InputHandler:
	get: return player.input

var player_data: PlayerData:
	get: return player.player_data

const STATE_IDLE := &"state_idle"
const STATE_WALK := &"state_walk"
const STATE_SCAN := &"state_scan"

## Accelerate movement. Handles various states. Used internally by move
func accelerate(_delta: float, input_dir: Vector2 = input.input_dir) -> void:
	var accel := player_data.acceleration
	var decel := player_data.deceleration

	var speed := player_data.speed
	if (fsm.current_state == STATE_SCAN):
		speed *= 0

	if not input.input_dir.is_zero_approx():
		player.velocity = player.velocity.move_toward(input.input_dir * speed, accel * _delta)
	else:
		player.velocity = player.velocity.move_toward(Vector2.ZERO, decel * _delta)

## Applies Movement. Call in any state whenever movement is applicable, passing certain parameters.
func move(delta: float, direction: Vector2 = input.input_dir) -> void:
	accelerate(delta, direction)
	player.move_and_slide()
