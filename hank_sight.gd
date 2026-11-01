extends Node3D
class_name HankSight





var rays: Array[RayCast3D] = []



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is RayCast3D:
			rays.append(child)




func _raycast_sees_player(raycast: RayCast3D) -> bool:
	if raycast.is_colliding() and raycast.get_collider() is HankSightArea:
		return true
	return false


func can_see_player() -> bool:
	for ray in rays:
		if _raycast_sees_player(ray):
			return true
	return false
