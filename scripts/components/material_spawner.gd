extends Node2D

@export var materials: Array[PackedScene]
@export var quantity: int = 10
@export var spawn_shape: CollisionShape2D
@export var time_data: TimeData

@export var debug_label: Label

var rng = RandomNumberGenerator.new()

var random_quantities = [1, 2, 5, 10, 25, 50, 100]
var weights = PackedFloat32Array([1, 1, 2, 1.5, 0.8, 0.5, 0.1])

var spawned_nodes: Array[Node2D] = []

func _ready() -> void:
	spawn_materials()
	debug_label.hide()
	time_data.day_time_changed.connect(func(_td: TimeData.DayTime, _d: int): spawn_materials())

func spawn_materials() -> void:
	if not materials:
		return

	for n in spawned_nodes:
		if n and is_instance_valid(n): n.queue_free()
	spawned_nodes.clear()

	var shape: RectangleShape2D = spawn_shape.shape
	var size := shape.size

	randomize()
	for i in range(quantity):
		var m: PackedScene = materials.pick_random()
		var mNode: MaterialPickable = m.instantiate()
		self.add_child(mNode)
		mNode.position = Vector2(
			randf_range(0 - size.x / 2, 0 + size.x / 2),
			randf_range(0 - size.y / 2, 0 + size.y / 2)
		)

		mNode.set_quantity(random_quantities[rng.rand_weighted(weights)])
		mNode.sprite.scale *= (1 + (mNode.quantity / random_quantities.max()))
		spawned_nodes.append(mNode)
