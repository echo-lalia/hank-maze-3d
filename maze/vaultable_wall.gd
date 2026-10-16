@tool
extends Node3D
class_name VaultableWall


@onready var csg_box_3d: CSGBox3D = $CSGBox3D
@onready var collision_shape_3d: CollisionShape3D = $StaticBody3D/CollisionShape3D



@export var width: float = 4.0:
	set(val):
		width = val
		_update_shapes()
@export var height: float = 4.0:
	set(val):
		height = val
		_update_shapes()
@export var thickness: float = 0.4:
	set(val):
		thickness = val
		_update_shapes()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_shape_3d.shape = collision_shape_3d.shape.duplicate()
	_update_shapes()


func _update_shapes() -> void:
	csg_box_3d.size = Vector3(width, height / 2, thickness)
	csg_box_3d.position.y = height / 4
	collision_shape_3d.shape.size = Vector3(width, height, thickness)
	collision_shape_3d.position.y = height / 2


func _on_interactable_area_interacted(player: PlayerBody) -> void:
	# JUST FOR TESTING
	queue_free()
