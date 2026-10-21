extends HankState


@export var running_state: State



const PATROL_DISTANCE: float = 10.0
const PATROL_DISTANCE_PHASE2: float = 15.0
const PATROL_MAX_PATH: float = 15.0
const PATROL_MAX_PHASE2: float = 20.0



## Called when entering this state
func enter() -> void:
	auto_animation = false
	playing_animation = HANK_ANIMATION.looking_frantic if hank_mesh.saw_player_recently else HANK_ANIMATION.looking
	await get_tree().physics_frame
	
	if not hank_mesh.animation_player.animation_finished.is_connected(_looking_finished):
		hank_mesh.animation_player.animation_finished.connect(_looking_finished)
	if not PlayerBody.current_player_instance.played_sound.is_connected(_on_player_sound):
		PlayerBody.current_player_instance.played_sound.connect(_on_player_sound)


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
		state_machine.current_state = running_state




func _looking_finished(anim_name: StringName) -> void:
	if not is_active_state() or not (anim_name == "LookingAction" or anim_name == "LookingFranticAction"):
		return
	
	# Set hank to a slightly lower speed while patrolling.
	hank_body.hank_speed = GameRun.phase2_switchf(HankBody.HANK_SPEED_PATROL_1, HankBody.HANK_SPEED_PATROL_2)
	if hank_mesh.saw_player_recently:
		hank_body.hank_speed += 2
	
	# Select a random nearby point to patrol to.
	var direction: Vector3 = Vector3(
		GameRun.phase2_switchf(PATROL_DISTANCE, PATROL_DISTANCE_PHASE2),
		0,
		0,
	).rotated(Vector3(0, 1, 0), randf_range(0, deg_to_rad(360)))

	target_position = global_position + direction
	hank_body.navigation_agent_3d.get_next_path_position()
	
	if hank_body.navigation_agent_3d.get_path_length() > GameRun.phase2_switchf(PATROL_MAX_PATH, PATROL_MAX_PHASE2):
		# The path is too long and we need to sample a point closer to us along the navigation path.
		# We should be able to pick a point along the path that's one before the first one outside of our max range.
		var navigation_path := hank_body.navigation_agent_3d.get_current_navigation_path()
		for i in range(1, len(navigation_path)):
			var point: Vector3 = navigation_path[i]
			if global_position.distance_to(point) > PATROL_MAX_PATH:
				target_position = navigation_path[i - 1]
				break
	
	hank_body.navigation_agent_3d.get_next_path_position()
	
	state_machine.current_state = running_state



## Called when leaving this state
func exit() -> void:
	if hank_mesh.animation_player.animation_finished.is_connected(_looking_finished):
		hank_mesh.animation_player.animation_finished.disconnect(_looking_finished)
	if PlayerBody.current_player_instance.played_sound.is_connected(_on_player_sound):
		PlayerBody.current_player_instance.played_sound.disconnect(_on_player_sound)
	
	
	auto_animation = true


## Called every physics frame while this state is active
func physics_update(_delta: float) -> void:
	if hank_mesh.animation_player.is_playing() and hank_mesh.sees_player:

		# We saw the player. Pause and see if they're really there.
		hank_mesh.animation_player.pause()

		await get_tree().create_timer(GameRun.phase2_switchf(0.4, 0.2)).timeout

		if is_active_state() and hank_mesh.sees_player:
			hank_body.hank_speed = GameRun.phase2_switchf(HankBody.HANK_SPEED_CHASE_1, HankBody.HANK_SPEED_CHASE_2)
			target_position = PlayerBody.current_player_instance.global_position
			state_machine.current_state = running_state
		else:
			GameRun.phase2_switchf(HankBody.HANK_SPEED_PATROL_1, HankBody.HANK_SPEED_PATROL_2)
			if not hank_mesh.animation_player.is_playing():
				hank_mesh.animation_player.play()
			override_head_look_at = Vector3.ZERO
