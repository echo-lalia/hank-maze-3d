extends HankState

@export var looking_state: State


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# hank_body.navigation_agent_3d.is_navigation_finished()
	pass # Replace with function body.


## Called when entering this state
func enter() -> void:
	auto_animation = true
	playing_animation = HANK_ANIMATION.running
	# Pass a physics frame to make sure we started running.
	await get_tree().physics_frame
	assert(auto_animation)
	if hank_body.navigation_agent_3d.is_navigation_finished():
		state_machine.current_state = looking_state


## Called when leaving this state
func exit() -> void:
	pass


## Called every physics frame while this state is active
func physics_update(_delta: float) -> void:
	if hank_mesh.sees_player:
		hank_body.target_position = PlayerBody.current_player_instance.global_position
	elif hank_body.navigation_agent_3d.is_navigation_finished():
		state_machine.current_state = looking_state
