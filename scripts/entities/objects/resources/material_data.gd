class_name MaterialData extends Resource

enum MaterialType {
	BUILDING,
	ENERGY
}

## Texture of the material visible in the map
@export var texture: Texture2D

## The material type
@export var mType: MaterialType

## Name of the material
@export var name: String

## Small description of the material
@export var description: String
