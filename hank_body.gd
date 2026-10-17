extends CharacterBody3D
class_name HankBody


const SPEED = 20.0
const ACCEL = 100.0

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D


static var current_hank_body_instance: HankBody


## The target position for the navigation agent.
var target_position: Vector3:
	set(val):
		target_position = val
		navigation_agent_3d.target_position = target_position


func _init() -> void:
	current_hank_body_instance = self


func _ready() -> void:
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent_3d.path_desired_distance = 1.0
	navigation_agent_3d.target_desired_distance = 1.0
	
	#target_position = PlayerBody.current_player_instance.global_position
	

func _physics_process(delta: float) -> void:
	#if PlayerBody.current_player_instance.movement_state != PlayerBody.MOVEMENT_STATES.sneak:
		#navigation_agent_3d.target_position = PlayerBody.current_player_instance.global_position
	navigation_agent_3d.debug_enabled = true
	
	var current_target_position: Vector3
	if navigation_agent_3d.is_navigation_finished():
		current_target_position = target_position
	else:
		current_target_position = navigation_agent_3d.get_next_path_position()
	
	if navigation_agent_3d.is_navigation_finished():
		var velocity_2d: Vector2 = Vector2(velocity.x, velocity.z).move_toward(Vector2.ZERO, delta * ACCEL)
		velocity.x = velocity_2d.x
		velocity.z = velocity_2d.y
	else:
	
		var direction_2d: Vector2 = Vector2(current_target_position.x - global_position.x, current_target_position.z - global_position.z).normalized()
		var target_velocity_2d: Vector2 = direction_2d * SPEED
		var velocity_2d: Vector2 = Vector2(velocity.x, velocity.z).move_toward(target_velocity_2d, delta * ACCEL)
		velocity.x = velocity_2d.x
		velocity.z = velocity_2d.y
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()
