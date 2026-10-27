extends HBoxContainer
class_name BottleUI


const BOTTLE_ICON = preload("uid://cqbin53ogo8qg")
const BOTTLE_ICON_BROKEN = preload("uid://bobha53smyqc0")

@onready var texture_rect: TextureRect = $TextureRect
@onready var bottles_label: Label = $BottlesLabel
@export var player: PlayerBody
@export var throw_source: Node3D


const BOTTLE = preload("uid://bv64vvydu2mo7")


var displayed_count: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_ui()



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("bottle") and player.remaining_bottles > 0:
		player.remaining_bottles -= 1
		_throw_bottle()


func _throw_bottle() -> void:
	var bottle: Bottle = BOTTLE.instantiate()
	bottle.position = throw_source.global_position
	player.maze_generator.add_child(bottle)
	bottle.global_position = throw_source.global_position
	bottle.rotation = Vector3(randf_range(deg_to_rad(-180), deg_to_rad(180)), randf_range(deg_to_rad(-180), deg_to_rad(180)), 0)
	bottle.linear_velocity = throw_source.global_basis.z * -12.0 + Vector3(0, 1, 0) + player.velocity
	bottle.angular_velocity = Vector3(randfn(0, 6), randfn(0, 1), randfn(0, 1))


func _update_ui() -> void:
	texture_rect.texture = BOTTLE_ICON if player.remaining_bottles else BOTTLE_ICON_BROKEN
	bottles_label.text = str(player.remaining_bottles) + " (" + Utils.action_as_key_string("bottle") + ")"
	displayed_count = player.remaining_bottles


func _process(_delta: float) -> void:
	if displayed_count != player.remaining_bottles:
		_update_ui()
