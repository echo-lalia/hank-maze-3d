extends Node3D
class_name HankDeathScreen





@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var color_rect: ColorRect = $Camera3D/ColorRect



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("hank_scare")
	animation_player.animation_finished.connect(_animation_finished)


func _animation_finished(_anim: StringName) -> void:
	if audio_stream_player.playing:
		color_rect.visible = true
		await audio_stream_player.finished
	Main.start_main_menu()
