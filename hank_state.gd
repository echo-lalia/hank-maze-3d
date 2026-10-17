extends State
class_name HankState

const HANK_ANIMATION = HankAlpeca.HANK_ANIMATION

var hank_body: HankBody:
	get:
		return (state_machine as HankStateMachine).hank_body
var hank_mesh: HankAlpeca:
	get:
		return (state_machine as HankStateMachine).hank_mesh


var global_position: Vector3:
	get:
		return hank_body.global_position
	set(val):
		hank_body.global_position = val
var target_position: Vector3:
	get:
		return hank_body.target_position
	set(val):
		hank_body.target_position = val

var playing_animation: HANK_ANIMATION:
	get:
		return hank_mesh.playing_animation
	set(val):
		hank_mesh.playing_animation = val

var auto_animation: bool:
	get:
		return hank_mesh.auto_animation
	set(val):
		hank_mesh.auto_animation = val

var override_head_look_at: Vector3:
	get:
		return hank_mesh.override_head_look_at
	set(val):
		hank_mesh.override_head_look_at = val

var override_head_lerp_factor: float:
	get:
		return hank_mesh.override_head_lerp_factor
	set(val):
		hank_mesh.override_head_lerp_factor = val
