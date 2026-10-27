extends RigidBody3D
class_name Bottle


#@onready var area_3d: Area3D = $Area3D
@onready var raytraced_audio_player_3d: RaytracedAudioPlayer3D = $RaytracedAudioPlayer3D
@onready var bottle_mesh: MeshInstance3D = $Cylinder_002
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D


func _on_hit(_collider: Node) -> void:
	set_physics_process(false)
	freeze = true
	gpu_particles_3d.emitting = true
	raytraced_audio_player_3d.play()
	PlayerBody.current_player_instance.played_sound.emit(global_position, 150)
	bottle_mesh.queue_free()




func _on_raytraced_audio_player_3d_finished() -> void:
	queue_free()
