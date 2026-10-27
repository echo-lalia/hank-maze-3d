extends Node3D
class_name HankAlpeca


const RUN_ANIMATION_TRAVEL: float = 2.0
const RUN_ANIMATION_DURATION: float = 0.1667
const RUN_ANIMATION_VELOCITY: float = RUN_ANIMATION_TRAVEL / RUN_ANIMATION_DURATION
const DIST_PER_STEP_SFX: float = 1

const CONE_VISION_ANGLE: float = deg_to_rad(60)
const STARE_PLAYER_MAX_ANGLE: float = deg_to_rad(75)
const CONE_VISION_DISTANCE: float = 5


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var armature: Node3D = $Armature
@onready var floor_detection_raycast: RayCast3D = $FloorDetectionRaycast
@onready var player_detection_raycast: RayCast3D = $Armature/Skeleton3D/BoneAttachment3D/PlayerDetectionRaycast
@onready var player_detection_raycast_2: RayCast3D = $Armature/Skeleton3D/BoneAttachment3D/PlayerDetectionRaycast2
@onready var player_detection_raycast_3: RayCast3D = $Armature/Skeleton3D/BoneAttachment3D/PlayerDetectionRaycast3
@onready var player_detection_raycast_4: RayCast3D = $Armature/Skeleton3D/BoneAttachment3D/PlayerDetectionRaycast4
@onready var player_detection_raycast_5: RayCast3D = $Armature/Skeleton3D/BoneAttachment3D/PlayerDetectionRaycast5


@onready var organ_sting_player: AudioStreamPlayer = $OrganStingPlayer
@onready var wall_detection_raycast_short: RayCast3D = $Armature/Skeleton3D/BoneAttachment3D/WallDetectionRaycastShort

@onready var bone_attachment_3d: BoneAttachment3D = $Armature/Skeleton3D/BoneAttachment3D

#@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var raytraced_audio_player_3d: RaytracedAudioPlayer3D = $RaytracedAudioPlayer3D

@export var auto_animation: bool = true
@export var auto_speed_direction: bool = true


const SAW_PLAYER_RECENTLY_THRESHOLD = 20000
var last_time_seeing_player: int = 0
var saw_player_recently: bool = false

var saw_player_last_frame: bool = false
var saw_player_this_frame: bool = false

var sees_player: bool = false

static var current_hank_mesh_instance: HankAlpeca


@export_flags_3d_physics var floor_detection_collision_mask: int = 1:
	set(val):
		floor_detection_collision_mask = val
		if not is_node_ready():
			await ready
		floor_detection_raycast.collision_mask = floor_detection_collision_mask


var override_head_look_at: Vector3
var override_head_lerp_factor: float = 0.5


enum HANK_ANIMATION {
	idle,
	running,
	falling,
	looking,
	looking_frantic,
}


## Update the currently playing hank animation.
var playing_animation: HANK_ANIMATION = HANK_ANIMATION.idle:
	set(val):
		playing_animation = val
		_update_playing_animation()



var previous_position: Vector3 = Vector3.ZERO
## The current velocity in M/S
var velocity: Vector3 = Vector3.ZERO



func _ready() -> void:
	current_hank_mesh_instance = self
	set_process(false)
	await InitScreen.await_init_screen()
	await get_tree().physics_frame
	
	
	if not Engine.is_editor_hint():
		_update_playing_animation()
	if OS.is_debug_build():
		await get_tree().process_frame
		PlayerBody.current_player_instance.played_sound.connect(_dbg_sound_heard)
	
	
	set_process(true)


func _dbg_sound_heard(sound_position: Vector3, travel_distance: float) -> void:
	if global_position.distance_to(sound_position) < travel_distance:
		print("Hank heard a sound at ", sound_position)
	else:
		print("A sound at ", sound_position, " was not audible to hank uh.")


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
		HANK_ANIMATION.looking:
			animation_player.play("LookingAction")
		HANK_ANIMATION.looking_frantic:
			animation_player.play("LookingFranticAction")
	
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
		_:
			animation_player.speed_scale = 1.0


var _step_sfx_current_distance: float = 0.0


func _raycast_sees_player(raycast: RayCast3D) -> bool:
	if raycast.is_colliding() and player_detection_raycast.get_collider() is HankSightArea:
		#print("RAYCAST SEES PLAYER")
		return true
	#print("RAYCAST SEES ", player_detection_raycast.get_collider())
	return false

func _player_in_vision_cone() -> bool:
	var player_direction_vector: Vector3 = player_detection_raycast.global_position.direction_to(PlayerBody.current_player_instance.global_position)
	var player_angle: float = (player_detection_raycast.global_basis.z).angle_to(player_direction_vector)
	return (
		player_angle < CONE_VISION_ANGLE
		and player_detection_raycast.global_position.distance_to(PlayerBody.current_player_instance.global_position) < CONE_VISION_DISTANCE
	)


func _can_look_at_point(point: Vector3) -> bool:
	var direction_vector: Vector3 = player_detection_raycast.global_position.direction_to(point)
	var angle: float = (global_basis.z).angle_to(direction_vector)
	return (angle < STARE_PLAYER_MAX_ANGLE)




func _handle_hank_lookat() -> void:
	if override_head_look_at and _can_look_at_point(override_head_look_at):
		bone_attachment_3d.override_pose = true
		var new_transform := (
			bone_attachment_3d.global_transform
			.looking_at(override_head_look_at, Vector3.UP, true)
			.rotated_local(Vector3(1, 0, 0), 12)
		)
		bone_attachment_3d.global_transform = bone_attachment_3d.global_transform.interpolate_with(new_transform, override_head_lerp_factor)
	else:
		bone_attachment_3d.override_pose = false
	


func _process(delta: float) -> void:
	_step_sfx_current_distance += (global_position - previous_position).length()
	if _step_sfx_current_distance > DIST_PER_STEP_SFX:
		_step_sfx_current_distance = 0
		raytraced_audio_player_3d.play()
	
	velocity = (global_position - previous_position) / delta
	previous_position = global_position
	
	if auto_animation:
		if (not floor_detection_raycast.is_colliding()):
			playing_animation = HANK_ANIMATION.falling
		
		elif playing_animation == HANK_ANIMATION.idle and velocity.length() > 0.1:
			playing_animation = HANK_ANIMATION.running
		
		elif playing_animation == HANK_ANIMATION.running and velocity.length() < 0.1:
			playing_animation = HANK_ANIMATION.idle
	
	if auto_speed_direction:
		update_animation_speed_direction()
	
	
	# Handle player sight
	saw_player_last_frame = saw_player_this_frame
	
	if _raycast_sees_player(player_detection_raycast) \
	or _raycast_sees_player(player_detection_raycast_2) \
	or _raycast_sees_player(player_detection_raycast_3) \
	or _raycast_sees_player(player_detection_raycast_4) \
	or _raycast_sees_player(player_detection_raycast_5) \
	or (_player_in_vision_cone() and PlayerBody.current_player_instance.has_hank_line_of_sight):
		saw_player_this_frame = true
		last_time_seeing_player = Time.get_ticks_msec()
		if not saw_player_recently:
			organ_sting_player.play()
	else:
		saw_player_this_frame = false
	
	sees_player = saw_player_this_frame or saw_player_last_frame
	
	if Time.get_ticks_msec() - last_time_seeing_player < SAW_PLAYER_RECENTLY_THRESHOLD:
		saw_player_recently = true
	else:
		saw_player_recently = false
	
	
	
	_handle_hank_lookat()
	
	#print("sees_player = ", sees_player)
	
	
	



	
