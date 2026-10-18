extends Node3D

@onready var interactable_area: InteractableArea = $InteractableArea
@export var maze_generator: MazeWallGenerator


const RICH_TEXT_3D = preload("uid://dtyqi7x7atmdo")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable_area.interacted.connect(_on_interacted)
	
	if not maze_generator.is_node_ready():
		await maze_generator.ready
	global_position = maze_generator.start_room_position.global_position


func _on_interacted(player: PlayerBody) -> void:
	if player.has_gourd:
		player.win()
	else:
		var notify_text: RichText3D = RICH_TEXT_3D.instantiate()
		notify_text.text = "Can't leave without it..."
		notify_text.size = Vector2(120, 200)
		notify_text.scale = Vector3(2, 2, 2)
		notify_text.position = Vector3(0, 1.5, -2.8)
		
		add_child(notify_text)
		get_tree().create_timer(2).timeout.connect(notify_text.queue_free)
