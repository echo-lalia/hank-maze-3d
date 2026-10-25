extends Node3D

@onready var interactable_area: InteractableArea = $InteractableArea
@export var maze_generator: MazeWallGenerator
@onready var rich_text_3d: RichText3D = $RichText3D
@onready var door_open_sound_player: AudioStreamPlayer = $DoorOpenSoundPlayer

const INITIAL_TEXT = "FIND IT"

#const RICH_TEXT_3D = preload("uid://dtyqi7x7atmdo")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable_area.interacted.connect(_on_interacted)
	
	rich_text_3d.visible = true
	rich_text_3d.text = INITIAL_TEXT
	
	if not maze_generator.is_node_ready():
		await maze_generator.ready
	global_position = maze_generator.start_room_position.global_position
	
	await get_tree().create_timer(3.0).timeout
	if rich_text_3d.text == INITIAL_TEXT:
		rich_text_3d.visible = false


func _on_interacted(player: PlayerBody) -> void:
	if player.has_gourd:
		player.win()
	else:
		door_open_sound_player.play()
		rich_text_3d.visible = true
		rich_text_3d.text = "Can't leave without it..."
		await get_tree().create_timer(2).timeout
		rich_text_3d.visible = false
		
		#var notify_text: RichText3D = RICH_TEXT_3D.instantiate()
		#notify_text.text = "Can't leave without it..."
		#notify_text.size = Vector2(120, 200)
		#notify_text.scale = Vector3(2, 2, 2)
		#notify_text.position = Vector3(0, 1.5, -2.8)
		
		#add_child(notify_text)
		#get_tree().create_timer(2).timeout.connect(notify_text.queue_free)
