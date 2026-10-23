extends Area3D

@export var player: PlayerBody

@export var player_damage_effect: TextureRect

const HURT_AMOUNT: float = 1.0
const HEAL_AMOUNT: float = 0.1
const MAX_TENSE_VOLUME: float = 0.4

@onready var collision_shape_3d_small: CollisionShape3D = $CollisionShape3DSmall
@onready var collision_shape_3d_big: CollisionShape3D = $CollisionShape3DBig
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


var use_big_collider: bool = false:
	set(val):
		use_big_collider = val
		collision_shape_3d_big.disabled = not use_big_collider
		collision_shape_3d_small.disabled = use_big_collider


var health: float = 1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_stream_player.volume_linear = 0
	audio_stream_player.play()
	use_big_collider = false


var _hank_angle: float = 0.0
var _hint_angle: float = 0.0
func _physics_process(delta: float) -> void:
	var bodies := get_overlapping_bodies()

	if use_big_collider and (not bodies):
		use_big_collider = false
	elif (not use_big_collider) and bodies:
		use_big_collider = true
	
	if bodies and player.has_hank_line_of_sight:
		assert(bodies[0] is HankBody)
		health -= delta * HURT_AMOUNT
	else:
		health += delta * HEAL_AMOUNT
	
	health = clampf(health, 0, 1)
	
	_hank_angle = lerpf(
		_hank_angle,
		-(Vector3.FORWARD).signed_angle_to(HankBody.current_hank_body_instance.global_position-global_position, Vector3.UP),
		0.03
	)
	_hint_angle = lerpf(_hint_angle, _hank_angle + player.player_head.rotation.y, 0.3)
	(player_damage_effect.material as ShaderMaterial).set_shader_parameter("hint_angle", _hint_angle)
	(player_damage_effect.material as ShaderMaterial).set_shader_parameter("amount", pow(1.0 - health, 0.5))
	
	audio_stream_player.volume_linear = (1.0 - health) * MAX_TENSE_VOLUME
	
	if is_zero_approx(health):
		player.lose()
	
	player_damage_effect.visible = not is_zero_approx(health)
	
	#use_big_collider = falsea
	#assert(not (collision_shape_3d_small.disabled and collision_shape_3d_big.disabled))
	
	


func _on_body_entered(_body: Node3D) -> void:
	pass # Replace with function body.
