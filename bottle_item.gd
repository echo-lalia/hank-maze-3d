extends Node3D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interactable_area: InteractableArea = $InteractableArea
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var mesh: Node3D = $Mesh



func _on_interactable_area_interacted(player: PlayerBody) -> void:
	player.remaining_bottles += 1
	mesh.queue_free()
	animation_player.queue_free()
	interactable_area.queue_free()
	
	audio_stream_player.finished.connect(queue_free)
	audio_stream_player.play()
	
