extends Node3D

@onready var interactable_area: InteractableArea = $InteractableArea
@export var maze_generator: MazeWallGenerator


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable_area.interacted.connect(_on_interacted)
	
	if not maze_generator.is_node_ready():
		await maze_generator.ready
	global_position = maze_generator.end_room_position.global_position
	


func _on_interacted(player: PlayerBody) -> void:
	player.has_gourd = true
	GameRun.current_game_run.start_phase_two()
	queue_free()
