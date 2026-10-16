extends Area3D
class_name InteractableArea


@export var ui_hint: String = "Interact"


## Emitted when the interact function is executed by the given player body.
signal interacted(player: PlayerBody)


func _init() -> void:
	monitoring = false
	monitorable = true
	input_ray_pickable = false
	collision_layer = 16
	collision_mask = 16


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


## Call this to interact with this object.
func interact(player: PlayerBody) -> void:
	interacted.emit(player)
