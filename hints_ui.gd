extends HBoxContainer
class_name HintsUi


const BONE_ICON = preload("uid://d38sigpehbcnc")
const BONE_ICON_BROKEN = preload("uid://kb84iwkxmu03")

@onready var texture_rect: TextureRect = $TextureRect
@onready var hints_label: Label = $HintsLabel
@export var player: PlayerBody
const BONE_CRACK_AUDIO_STREAM_RANDOMIZER = preload("uid://blsngu0i4ly3y")
@onready var bone_animation_player: AnimationPlayer = $"../../BoneRoot/BoneAnimationPlayer"
@onready var player_audio_player: PlayerAudioPlayer = $"../../BoneRoot/PlayerAudioPlayer"


const PATH_HINT = preload("uid://b6qma5cmho1kv")


var displayed_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_ui()



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("hint") and player.remaining_hints > 0 and not bone_animation_player.is_playing():
		player.remaining_hints -= 1
		_create_hint()


func _create_hint() -> void:
	bone_animation_player.play("bone_crack")
	await get_tree().create_timer(0.3).timeout
	player_audio_player.play_player_sound_from_position(player.position, BONE_CRACK_AUDIO_STREAM_RANDOMIZER, 100, db_to_linear(-3))
	
	var hint_path: PathHint = PATH_HINT.instantiate()
	hint_path.maze_generator = player.maze_generator
	player.maze_generator.add_child(hint_path)
	hint_path.global_position = player.global_position


func _update_ui() -> void:
	texture_rect.texture = BONE_ICON if player.remaining_hints else BONE_ICON_BROKEN
	hints_label.text = str(player.remaining_hints) + " (" + Utils.action_as_key_string("hint") + ")"
	displayed_count = player.remaining_hints


func _process(_delta: float) -> void:
	if displayed_count != player.remaining_hints:
		_update_ui()
