class_name Player extends CharacterBody2D

@export var player_data: PlayerData
@export var state_machine: StateMachine
@export var input: InputHandler
@export var inventory: InventoryManager
#@export var interaction_finder: InteractionFinder
#@export var hurtbox: HurtBox
#@export var health: Health

var controls_enabled := true
var camera: PhantomCamera2D = null

#var direction := Vector2.ZERO

func _ready() -> void:
	assert(player_data != null, "Player Data Not Set!")
	state_machine.init(self)

	#hurtbox.took_damage.connect(_took_damage)
	#health.died.connect(game_over)

	#unlock_controls()

func _process(_delta: float) -> void:
	if controls_enabled:
		input.update()

func _took_damage(amount: int, hitbox_position: Vector2, knockback: float):
	#var shake = procam.get_addons()[0]
	#shake.shake()
	await get_tree().create_timer(0.2).timeout
	#shake.stop()

func lock_controls() -> void:
	controls_enabled = false
	input.input_dir = Vector2.ZERO
	velocity = Vector2.ZERO

func unlock_controls() -> void:
	#print("Controls Unlocked")
	controls_enabled = true

func game_over() -> void:
	#SceneManager.change_scene("res://Scenes/main_menu.tscn")
	queue_free()
