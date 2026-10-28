extends VisibleOnScreenNotifier3D



@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await InitScreen.await_init_screen()
	await get_tree().create_timer(0.5).timeout
	screen_entered.connect(_on_screen_entered)


func _on_screen_entered() -> void:
	# Prevent imperceptable hank blips from triggering the sound.
	await get_tree().process_frame
	await get_tree().create_timer(0.05).timeout
	if not is_on_screen():
		return

	screen_entered.disconnect(_on_screen_entered)
	audio_stream_player.finished.connect(queue_free)
	audio_stream_player.play()
	
