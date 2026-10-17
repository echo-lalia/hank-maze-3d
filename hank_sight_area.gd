extends Area3D
class_name HankSightArea



@onready var normal_shape: CollisionShape3D = $NormalShape
@onready var sneak_shape: CollisionShape3D = $SneakShape
@onready var run_shape: CollisionShape3D = $RunShape


@export var player_body: PlayerBody




func _set_visible_shape() -> void:
	match player_body.movement_state:
		PlayerBody.MOVEMENT_STATES.sneak:
			normal_shape.disabled = true
			sneak_shape.disabled = false
			run_shape.disabled = true
		PlayerBody.MOVEMENT_STATES.sprint:
			normal_shape.disabled = true
			sneak_shape.disabled = true
			run_shape.disabled = false
		_:
			normal_shape.disabled = false
			sneak_shape.disabled = true
			run_shape.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	_set_visible_shape()
