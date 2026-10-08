@tool
extends Node3D
class_name HankAlpeca


const RUN_ANIMATION_TRAVEL: float = 4.0
const RUN_ANIMATION_DURATION: float = 0.1667
const RUN_ANIMATION_VELOCITY: float = RUN_ANIMATION_TRAVEL / RUN_ANIMATION_DURATION


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var armature: Node3D = $Armature
@onready var floor_detection_raycast: RayCast3D = $FloorDetectionRaycast

@export var auto_animation: bool = true
@export var auto_speed_direction: bool = true


@export_flags_3d_physics var floor_detection_collision_mask: int = 1:
	set(val):
		floor_detection_collision_mask = val
		if not is_node_ready():
			await ready
		floor_detection_raycast.collision_mask = floor_detection_collision_mask



enum HANK_ANIMATION {
	idle,
	running,
	falling,
}


var playing_animation: HANK_ANIMATION = HANK_ANIMATION.idle:
	set(val):
		playing_animation = val
		_update_playing_animation()



var previous_position: Vector3 = Vector3.ZERO
## The current velocity in M/S
var velocity: Vector3 = Vector3.ZERO


func _update_playing_animation() -> void:
	if not is_node_ready():
		await ready

	match playing_animation:
		HANK_ANIMATION.idle:
			animation_player.play("IdleAction")
		HANK_ANIMATION.falling:
			animation_player.play("FallingAction")
		HANK_ANIMATION.running:
			animation_player.play("RunAction")
	
	animation_player.speed_scale = 1.0


func update_animation_speed_direction() -> void:
	match playing_animation:
		HANK_ANIMATION.running:
			var speed_scale: float = velocity.length() / RUN_ANIMATION_VELOCITY
			animation_player.speed_scale = speed_scale
			
			var running_velocity: Vector3 = velocity * Vector3(1, 0, 1)
			var running_speed_squared: float = running_velocity.length_squared()
			if running_speed_squared > 0.05:
				var move_direction: float = Vector3.MODEL_FRONT.signed_angle_to(running_velocity, Vector3.UP)
				if running_speed_squared < 0.5:
					rotation.y = lerpf(rotation.y, move_direction, 0.5)
				else:
					rotation.y = move_direction


func _process(delta: float) -> void:
	velocity = (global_position - previous_position) / delta
	previous_position = global_position
	
	if auto_animation:
		if (not Engine.is_editor_hint()) and (not floor_detection_raycast.is_colliding()):
			playing_animation = HANK_ANIMATION.falling
		
		elif playing_animation == HANK_ANIMATION.idle and velocity.length() > 0.1:
			playing_animation = HANK_ANIMATION.running
		
		elif playing_animation == HANK_ANIMATION.running and velocity.length() < 0.1:
			playing_animation = HANK_ANIMATION.idle
	
	if auto_speed_direction:
		update_animation_speed_direction()
