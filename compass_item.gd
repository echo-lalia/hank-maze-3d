extends Node3D

@onready var compass_mesh: Node3D = $CompassMesh
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interactable_area: InteractableArea = $InteractableArea
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer



static var extant_compasses: Array[Node3D] = []


func _enter_tree() -> void:
	extant_compasses.append(self)


func _exit_tree() -> void:
	extant_compasses.erase(self)


func _on_interactable_area_interacted(player: PlayerBody) -> void:
	for compass in extant_compasses:
		if compass and compass != self:
			compass.queue_free()
	extant_compasses.clear()
	
	player.has_compass = true
	compass_mesh.queue_free()
	animation_player.queue_free()
	interactable_area.queue_free()
	
	audio_stream_player.finished.connect(queue_free)
	audio_stream_player.play()
