extends Node3D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interactable_area: InteractableArea = $InteractableArea
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var bone_mesh: Node3D = $BoneMesh



func _on_interactable_area_interacted(player: PlayerBody) -> void:
	player.remaining_hints += 1
	bone_mesh.queue_free()
	animation_player.queue_free()
	interactable_area.queue_free()
	
	audio_stream_player.finished.connect(queue_free)
	audio_stream_player.play()
	
