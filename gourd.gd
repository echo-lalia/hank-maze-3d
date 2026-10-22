extends Node3D

@onready var interactable_area: InteractableArea = $InteractableArea
@export var maze_generator: MazeWallGenerator
@onready var rich_text_3d: RichText3D = $RichText3D
@onready var gourd_mesh: MeshInstance3D = $GourdMesh
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rich_text_3d.visible = false
	interactable_area.interacted.connect(_on_interacted)
	
	if not maze_generator.is_node_ready():
		await maze_generator.ready
	global_position = maze_generator.end_room_position.global_position
	


func _on_interacted(player: PlayerBody) -> void:
	gourd_mesh.queue_free()
	interactable_area.queue_free()
	rich_text_3d.visible = true
	rich_text_3d.look_at(player.global_position, Vector3.UP, true)
	rich_text_3d.rotation.x = 0
	rich_text_3d.rotation.z = 0
	
	player.has_gourd = true
	GameRun.current_game_run.start_phase_two()
	reparent(player)
	audio_stream_player.play()
	
	await get_tree().create_timer(1.0).timeout
	PlayerBody.current_player_instance.played_sound.emit(
		global_position,
		1000,
	)
	await get_tree().create_timer(2.0).timeout
	queue_free()
