extends Area3D

@export var player: PlayerBody

@export var player_damage_effect: TextureRect

const HURT_AMOUNT: float = 2.0
const HEAL_AMOUNT: float = 0.1


@onready var collision_shape_3d_small: CollisionShape3D = $CollisionShape3DSmall
@onready var collision_shape_3d_big: CollisionShape3D = $CollisionShape3DBig


var use_big_collider: bool = false:
	set(val):
		use_big_collider = val
		collision_shape_3d_big.disabled = not use_big_collider
		collision_shape_3d_small.disabled = use_big_collider


var health: float = 1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	use_big_collider = false


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
	
	(player_damage_effect.material as ShaderMaterial).set_shader_parameter("amount", 1.0 - health)
	
	if is_zero_approx(health):
		Main.start_hank_death_screen()
	
