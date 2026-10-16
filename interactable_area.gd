extends Area3D
class_name InteractableArea


@export var ui_hint: String = "Interact"
@export_range(0, 10, 0.01, "or_greater", "suffix:s") var interact_disable_duration: float = 0.5


## Emitted when the interact function is executed by the given player body.
signal interacted(player: PlayerBody)


func _init() -> void:
	monitoring = false
	monitorable = true
	input_ray_pickable = false
	collision_layer = 16
	collision_mask = 16




## Call this to interact with this object.
func interact(player: PlayerBody) -> void:
	process_mode = PROCESS_MODE_DISABLED
	interacted.emit(player)
	
	await get_tree().create_timer(interact_disable_duration).timeout
	process_mode = PROCESS_MODE_INHERIT
	
