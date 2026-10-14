extends CharacterBody3D
class_name PlayerBody


const SNEAK_SPEED: float = 2.0
const SPEED: float = 5.0
const SPRINT_SPEED: float = 10.0

const NORMAL_ACCEL: float = 80.0
const AIR_ACCEL: float = 10.0

const JUMP_VELOCITY = 4.5


enum MOVEMENT_STATES {
	normal,
	sneak,
	sprint,
	midair,
}

var movement_state: MOVEMENT_STATES = MOVEMENT_STATES.normal

@export var player_head: PlayerHead


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction_2d: Vector2 = input_dir.normalized().rotated(-player_head.rotation.y)
	
	# Rotate move direction with look direction.
	#direction_2d = direction_2d.rotated(Vector3.UP, player_head.rotation.y)
	
	movement_state = (
		MOVEMENT_STATES.midair if not is_on_floor()
		else MOVEMENT_STATES.sneak if Input.is_action_pressed("sneak")
		else MOVEMENT_STATES.sprint if Input.is_action_pressed("sprint")
		else MOVEMENT_STATES.normal
	)
	
	var speed: float = (
		SNEAK_SPEED if movement_state == MOVEMENT_STATES.sneak
		else SPRINT_SPEED if movement_state == MOVEMENT_STATES.sprint
		else SPRINT_SPEED if (movement_state == MOVEMENT_STATES.midair and Input.is_action_pressed("sprint"))
		else SPEED
	)
	var accel: float = AIR_ACCEL if movement_state == MOVEMENT_STATES.midair else NORMAL_ACCEL
	var target_velocity_2d: Vector2 = direction_2d * speed
	
	# Apply acceleration to velocity change.
	var velocity_2d: Vector2 = Vector2(velocity.x, velocity.z).move_toward(target_velocity_2d, accel * delta)
	velocity.x = velocity_2d.x
	velocity.z = velocity_2d.y
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
