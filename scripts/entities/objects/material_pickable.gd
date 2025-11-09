class_name MaterialPickable extends StaticBody2D

@export_category("Material Data")
@export var material_data: MaterialData
@export var quantity := 1

@export_category("References")
@export var sprite: Sprite2D


const TAG := "MaterialPickable"

func _ready() -> void:
	if not material_data:
		push_error("Material Data not Set")
		return

	CLogger.l(TAG, "Setting texture to %s" % material_data.texture)
	sprite.texture = material_data.texture

func pick() -> void:
	CLogger.l(TAG, "Picked Material %s x%d" % [material_data.name, quantity])
	queue_free()
