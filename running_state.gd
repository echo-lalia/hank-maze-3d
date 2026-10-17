extends HankState

@export var looking_state: State




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


## Called every physics frame while this state is active
func physics_update(_delta: float) -> void:
	if hank_mesh.sees_player:
		hank_body.target_position = PlayerBody.current_player_instance.global_position
		override_head_look_at = PlayerBody.current_player_instance.global_position
	
	elif hank_body.navigation_agent_3d.is_navigation_finished():
		state_machine.current_state = looking_state
		override_head_look_at = Vector3.ZERO
