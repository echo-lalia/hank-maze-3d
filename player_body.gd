extends CharacterBody3D
class_name PlayerBody


const PLAYER_STEP_AUDIO_STREAM_RANDOMIZER = preload("uid://dvscylno686kl")
const BIG_STOP_RANDOM_STREAM = preload("uid://b4f4mdt8nxoxp")


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


## True if the player has taken the gourd.
var has_gourd: bool = false


@onready var player_collision_normal: CollisionShape3D = $PlayerCollisionNormal
@onready var player_collision_sneak: CollisionShape3D = $PlayerCollisionSneak
@onready var interaction_raycast: RayCast3D = $PlayerHead/PlayerCamera/InteractionRaycast
@onready var interaction_label: Label = $PlayerHead/PlayerCamera/InteractionLabel
@onready var player_step_sound_player: PlayerAudioPlayer = $PlayerStepSoundPlayer
@onready var compass_sub_viewport_container: SubViewportContainer = $PlayerHead/PlayerCamera/CompassSubViewportContainer

@export var player_head: PlayerHead

@export var game_run: GameRun

@export var maze_generator: MazeWallGenerator

@warning_ignore("unused_signal")
## Emitted by PlayerAudioPlayer nodes when a hank audible sound is played.
signal played_sound(sound_position: Vector3, travel_distance: float)


var has_hank_line_of_sight: bool = false

var has_compass: bool = false:
	set(val):
		has_compass = val
		compass_sub_viewport_container.visible = has_compass


var locked_for_animation: bool = false
	#set(val):
		#locked_for_animation = val
		#process_mode = PROCESS_MODE_DISABLED if locked_for_animation else PROCESS_MODE_INHERIT
		

## Helper for accessing player head rotation.
var head_rotation: Vector3:
	set(val):
		player_head.rotation = val
	get:
		return player_head.rotation


var movement_state: MOVEMENT_STATES = MOVEMENT_STATES.normal:
	set(val):
		if movement_state != val:
			# Play a loud step when finishing a jump
			if movement_state == MOVEMENT_STATES.midair:
				player_step_sound_player.play_player_sound_from_position(global_position, BIG_STOP_RANDOM_STREAM, GameRun.phase2_switchf(60, 75), -3.0)
			movement_state = val
			_switch_movement_state()


func _switch_movement_state() -> void:
	if not is_node_ready():
		await ready
	
	var is_sneaking: bool = movement_state == MOVEMENT_STATES.sneak
	player_collision_normal.set_deferred("disabled", is_sneaking)
	player_collision_sneak.set_deferred("disabled", not is_sneaking)



static var current_player_instance: PlayerBody

func _ready() -> void:
	current_player_instance = self
	set_physics_process(false)
	if maze_generator:
		if not maze_generator.is_node_ready():
			await maze_generator.ready
		global_position = maze_generator.start_room_position.global_position
	
	set_physics_process(true)



func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if (event as InputEventKey).get_keycode_with_modifiers() == 268435543:
			get_viewport().set_input_as_handled()


## Handle main player movement
func _handle_player_movement(delta: float) -> void:
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
	if OS.is_debug_build() and Input.is_action_pressed("dbg_fly"):
		velocity.y = JUMP_VELOCITY
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()


## Handle detection of interactable area.
func _handle_interactable_area() -> void:
	# collider SHOULD be an interactable area if it's not null.
	var interactable_area: InteractableArea = interaction_raycast.get_collider()
	if not interactable_area:
		interaction_label.visible = false
		return
	
	if Input.is_action_just_pressed("interact"):
		interactable_area.interact(self)
		interaction_label.visible = false
	else:
		interaction_label.visible = true
		interaction_label.text = interactable_area.ui_hint


func _physics_process(delta: float) -> void:
	_handle_interactable_area()
	if not locked_for_animation:
		_handle_player_movement(delta)
	
	# Handle the line of sight check.
	var space := get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.create(HankAlpeca.current_hank_mesh_instance.bone_attachment_3d.global_position, player_head.global_position, 1)
	params.hit_from_inside = true
	var result: Dictionary = space.intersect_ray(params)
	if "collider" in result and result["collider"] and result["collider"] is PlayerBody:
		has_hank_line_of_sight = true
	else:
		has_hank_line_of_sight = false


## Win the game.
func win() -> void:
	Main.game_save.last_run_time = game_run.get_run_time()
	Main.game_save.won_last_run = true
	if Main.game_save.last_run_time < Main.game_save.best_run_time:
		Main.game_save.best_run_time = Main.game_save.last_run_time
		Main.game_save.pb_last_run = true
	else:
		Main.game_save.pb_last_run = false
	Main.game_save.has_finished_run_ever = true
	Main.game_save.has_won_run_ever = true
	Main.save_game()
	Main.start_win_screen()


func lose() -> void:
	Main.game_save.last_run_time = game_run.get_run_time()
	Main.game_save.won_last_run = false
	Main.game_save.pb_last_run = false
	Main.game_save.has_finished_run_ever = true
	Main.save_game()
	Main.start_hank_death_screen()


## Travel distance per step sound
const STEP_SOUND_DISTANCE: float = 2.0
var _current_step_travel: float = 0.0
var _previous_global_position: Vector3 = position
## Handle playing player stepp sounds.
func _handle_step_sounds() -> void:
	_current_step_travel += global_position.distance_to(_previous_global_position)
	_previous_global_position = global_position
	if _current_step_travel > STEP_SOUND_DISTANCE:
		_current_step_travel -= STEP_SOUND_DISTANCE
		#print(MOVEMENT_STATES.find_key(movement_state))
		if movement_state == MOVEMENT_STATES.sneak:
			player_step_sound_player.play_player_sound_from_position(global_position, PLAYER_STEP_AUDIO_STREAM_RANDOMIZER, 10.0, -15.0)
		elif movement_state == MOVEMENT_STATES.sprint:
			player_step_sound_player.play_player_sound_from_position(global_position, PLAYER_STEP_AUDIO_STREAM_RANDOMIZER, GameRun.phase2_switchf(45, 60), -3.0)
		elif movement_state == MOVEMENT_STATES.normal:
			player_step_sound_player.play_player_sound_from_position(global_position, PLAYER_STEP_AUDIO_STREAM_RANDOMIZER, GameRun.phase2_switchf(30, 40), -9.0)


func _process(_delta: float) -> void:
	_handle_step_sounds()
	#print(Utils.seconds_to_timer(game_run.get_run_time()))
