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
var shelter: Node2D

#var direction := Vector2.ZERO

func _ready() -> void:
	assert(player_data != null, "Player Data Not Set!")
	state_machine.init(self)

	player_data.wrap_to_shelter.connect(_wrap_to_shelter)

	unlock_controls()

func _process(_delta: float) -> void:
	if controls_enabled:
		input.update()

func lock_controls() -> void:
	controls_enabled = false
	input.input_dir = Vector2.ZERO
	velocity = Vector2.ZERO

func unlock_controls() -> void:
	controls_enabled = true

func game_over() -> void:
	#SceneManager.change_scene("res://Scenes/main_menu.tscn")
	queue_free()

func _wrap_to_shelter() -> void:
	self.global_position = shelter.global_position

func _exit_tree() -> void:
	player_data.wrap_to_shelter.disconnect(_wrap_to_shelter)
