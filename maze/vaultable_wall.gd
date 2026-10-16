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
	if not is_node_ready():
		return
	csg_box_3d.size = Vector3(width, height, thickness)
	csg_box_3d.position.y = height / 2
	collision_shape_3d.shape.size = Vector3(width, height, thickness)
	collision_shape_3d.position.y = height / 2


func _on_interactable_area_interacted(player: PlayerBody) -> void:
	var point_start: Vector3 = to_global(Vector3(0, 0, 0.5))
	var point_end: Vector3 = to_global(Vector3(0, 0, -0.5))
	var mid_point: Vector3 = point_start.lerp(point_end, 0.5) + Vector3(0, 0.5, 0)
	
	# point_start should be the one closer to player. If it isn't, swap them!
	if player.global_position.distance_to(point_end) < player.global_position.distance_to(point_start):
		var temp: Vector3 = point_start
		point_start = point_end
		point_end = temp
	
	player.locked_for_animation = true
	var tween: Tween = create_tween()
	if player.global_position.distance_to(point_start) > 2:
		tween.tween_property(player, "global_position", point_start, 0.1)
	tween.tween_property(player, "global_position", mid_point, 0.2)
	tween.tween_property(player, "global_position", point_end, 0.1)
	tween.tween_property(player, "locked_for_animation", false, 0)
