extends HankState

@export var looking_state: State



const LITTLE_MOVEMENT_DIST_THRESHOLD_SQUARED = 0.5
const MAX_TIME_LITTLE_MOVEMENT = 5.0


func _on_player_sound(sound_position: Vector3, travel_distance: float) -> void:
	if not is_active_state():
		return
	if global_position.distance_to(sound_position) < travel_distance:
		# Hank heard that.
		if hank_mesh.sees_player:
			# Ignore sounds if we can see the player.
			return
		# Go to the sound.
		target_position = sound_position



## Called when entering this state
func enter() -> void:
	time_not_moving = 0
	_smooth_prev_global_position = global_position
	auto_animation = true
	playing_animation = HANK_ANIMATION.running
	override_head_lerp_factor = 0.8
	override_head_look_at = Vector3.ZERO
	
	# Pass a physics frame to make sure we started running.
	await get_tree().physics_frame
	
	if hank_body.navigation_agent_3d.is_navigation_finished():
		state_machine.current_state = looking_state
	
	if not PlayerBody.current_player_instance.played_sound.is_connected(_on_player_sound):
		PlayerBody.current_player_instance.played_sound.connect(_on_player_sound)


## Called when leaving this state
func exit() -> void:
	if PlayerBody.current_player_instance.played_sound.is_connected(_on_player_sound):
		PlayerBody.current_player_instance.played_sound.disconnect(_on_player_sound)


var _smooth_prev_global_position: Vector3 = Vector3.ZERO
var time_not_moving: float = 0.0
## Called every physics frame while this state is active
func physics_update(delta: float) -> void:
	if hank_mesh.sees_player:
		hank_body.hank_speed = GameRun.phase2_switchf(HankBody.HANK_SPEED_CHASE_1, HankBody.HANK_SPEED_CHASE_2)
		hank_body.target_position = PlayerBody.current_player_instance.global_position
		override_head_look_at = PlayerBody.current_player_instance.global_position
	
	elif hank_body.navigation_agent_3d.is_navigation_finished():
		state_machine.current_state = looking_state
		override_head_look_at = Vector3.ZERO

	if _smooth_prev_global_position.distance_squared_to(global_position) < LITTLE_MOVEMENT_DIST_THRESHOLD_SQUARED:
		time_not_moving += delta
		if time_not_moving > MAX_TIME_LITTLE_MOVEMENT:
			print("Hank hasn't been moving much; unsticking him.")
			target_position = global_position
			state_machine.current_state = looking_state
			override_head_look_at = Vector3.ZERO
	
	_smooth_prev_global_position = _smooth_prev_global_position.lerp(global_position, delta)
