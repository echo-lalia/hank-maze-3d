extends CharacterBody3D


const SPEED = 20.0
const ACCEL = 100.0

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D


func _ready() -> void:
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent_3d.path_desired_distance = 1.0
	navigation_agent_3d.target_desired_distance = 1.0
	
	await get_tree().physics_frame
	navigation_agent_3d.target_position = PlayerBody.current_player_instance.global_position
	

func _physics_process(delta: float) -> void:
	if PlayerBody.current_player_instance.movement_state != PlayerBody.MOVEMENT_STATES.sneak:
		navigation_agent_3d.target_position = PlayerBody.current_player_instance.global_position
	navigation_agent_3d.debug_enabled = true

	var target_position: Vector3 = navigation_agent_3d.get_next_path_position()
	
	
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	var direction_2d: Vector2 = Vector2(target_position.x - global_position.x, target_position.z - global_position.z).normalized()
	var target_velocity_2d: Vector2 = direction_2d * SPEED
	var velocity_2d: Vector2 = Vector2(velocity.x, velocity.z).move_toward(target_velocity_2d, delta * ACCEL)
	velocity.x = velocity_2d.x
	velocity.z = velocity_2d.y
	
	#velocity = global_position.direction_to(target_position) * SPEED

	move_and_slide()
