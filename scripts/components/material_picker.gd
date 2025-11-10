class_name MaterialPicker extends Area2D

@export var inventory: InventoryManager

func _ready() -> void:
	self.body_entered.connect(_on_material_entered)

func _exit_tree() -> void:
	self.body_entered.disconnect(_on_material_entered)

func _on_material_entered(body: Node2D) -> void:
	if not body is MaterialPickable:
		return

	var obj := body as MaterialPickable
	inventory.add_many(obj.material_data, obj.quantity)
	obj.pick()
