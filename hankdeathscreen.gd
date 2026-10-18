extends Node3D
class_name HankDeathScreen





@onready var animation_player: AnimationPlayer = $AnimationPlayer




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("hank_scare")
	animation_player.animation_finished.connect(_animation_finished)


func _animation_finished(_anim: StringName) -> void:
	Main.start_main_menu()
