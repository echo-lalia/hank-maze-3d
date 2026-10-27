extends RaytracedAudioPlayer3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await InitScreen.await_init_screen()
	
	if not PlayerBody.current_player_instance:
		await get_tree().process_frame
	PlayerBody.current_player_instance.played_sound.connect(_play_hankapeka_maybe)





const HANKAPEKA_COOLDOWN = 4000
var _last_hankapeka_time: int = 0
func _play_hankapeka_maybe(sound_position: Vector3, travel_distance: float) -> void:
	if Time.get_ticks_msec() - _last_hankapeka_time > HANKAPEKA_COOLDOWN \
	and sound_position.distance_to(global_position) < travel_distance:
		_last_hankapeka_time = Time.get_ticks_msec()
		play()
