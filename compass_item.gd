extends Node3D

@onready var compass_mesh: Node3D = $CompassMesh
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interactable_area: InteractableArea = $InteractableArea
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer



func _on_interactable_area_interacted(player: PlayerBody) -> void:
	player.has_compass = true
	compass_mesh.queue_free()
	animation_player.queue_free()
	interactable_area.queue_free()
	
	audio_stream_player.finished.connect(queue_free)
	audio_stream_player.play()
	
