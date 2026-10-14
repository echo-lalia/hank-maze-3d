extends Node3D
class_name PlayerHead


const MOUSE_SPEED: float = 0.001


const NORMAL_HEAD_HEIGHT: float = 2.0
const SNEAK_HEAD_HEIGHT: float = 1.5


@export var player_body: PlayerBody



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y = move_toward(
		position.y,
		SNEAK_HEAD_HEIGHT if player_body.movement_state == PlayerBody.MOVEMENT_STATES.sneak else NORMAL_HEAD_HEIGHT,
		5.0 * delta,
	)
	



func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var screen_movement: Vector2 = (event as InputEventMouseMotion).screen_relative
		
		rotation = Vector3(
			clampf(rotation.x + (-screen_movement.y * MOUSE_SPEED), deg_to_rad(-85), deg_to_rad(89)),
			rotation.y + (-screen_movement.x * MOUSE_SPEED),
			0,
		)
