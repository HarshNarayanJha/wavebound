extends Control

@export var play_button: TextureButton
@export var credits_button: TextureButton
@export var quit_button: TextureButton

@export_file var playground_path: String
@export_file var help_scene_path: String
@export_file var credits_scene_path: String

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	SceneManager.change_scene(ResourceUID.uid_to_path(playground_path), {"color": Color.DARK_SEA_GREEN, "wait_time": 0.8, "speed": 1})

func _on_credits_pressed() -> void:
	print("Credits button pressed")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _exit_tree() -> void:
	play_button.pressed.disconnect(_on_play_pressed)
	credits_button.pressed.disconnect(_on_credits_pressed)
	quit_button.pressed.disconnect(_on_quit_pressed)
