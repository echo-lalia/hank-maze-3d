@tool
extends Node3D
class_name BoneFollower

@export var skeleton_3d: Skeleton3D
var bone_idx: int = -1
@export var bone_name: String:
	set(val):
		bone_name = val
		if not is_node_ready():
			await ready
		if skeleton_3d:
			bone_idx = skeleton_3d.find_bone(bone_name)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if bone_idx != -1:
		transform = skeleton_3d.get_bone_global_pose(bone_idx)
