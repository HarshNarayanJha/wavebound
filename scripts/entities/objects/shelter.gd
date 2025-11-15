class_name Shelter extends StaticBody2D

@export var debug := false
@export var shelter_data: ShelterData
@export var sprite: Sprite2D
@export var interaction_area: InteractionArea

const TAG := "Shelter"

func _ready() -> void:
	if not shelter_data:
		push_error("Shelter Data not provided")
		return

	if debug: CLogger.d(TAG, "Initializing shelter data")
	shelter_data.init()

	if debug: CLogger.d(TAG, "Current Health: %d" % shelter_data.get_current_health())
	if debug: CLogger.d(TAG, "Current State: " + shelter_data.ShelterState.keys()[shelter_data.get_current_state()])

	shelter_data.health_updated.connect(_update_sprite)
	interaction_area.interact.connect(_shelter_interact)
	_update_sprite(shelter_data.get_current_health(), shelter_data.get_current_health())

func _exit_tree() -> void:
	shelter_data.health_updated.disconnect(_update_sprite)
	interaction_area.interact.disconnect(_shelter_interact)

func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_0):
		CLogger.d(TAG, str(apply_damage(50)))

func apply_damage(amount: int) -> int:
	return shelter_data.apply_damage(amount)

func repair_damage(amount: int) -> int:
	return shelter_data.repair_damage(amount)

func _update_sprite(_o: int, _n: int):
	if debug: CLogger.d(TAG, "Updating sprite to " + str(shelter_data.get_current_sprite()))
	sprite.texture = shelter_data.get_current_sprite()
	interaction_area.action_name = shelter_data.get_current_action_name()

func _shelter_interact():
	if debug: CLogger.d(TAG, "Shelter interacted")
	repair_damage(20)
