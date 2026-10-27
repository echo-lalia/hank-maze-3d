extends VisibleOnScreenNotifier3D



@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


const OFF_SCREEN_DURATION_THRESHOLD = 60000


var hank_exit_screen_time: int = -30000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await InitScreen.await_init_screen()
	screen_entered.connect(_on_screen_entered)
	screen_exited.connect(_on_screen_exited)


func _han_enough_time_passed() -> bool:
	return (Time.get_ticks_msec() - hank_exit_screen_time > OFF_SCREEN_DURATION_THRESHOLD)


func _on_screen_entered() -> void:
	if _han_enough_time_passed():
		# Prevent imperceptable hank blips from triggering the sound.
		await get_tree().process_frame
		await get_tree().create_timer(0.05).timeout
		if (not is_on_screen()) or (not _han_enough_time_passed()):
			return

		audio_stream_player.play()



func _on_screen_exited() -> void:
	hank_exit_screen_time = Time.get_ticks_msec()
