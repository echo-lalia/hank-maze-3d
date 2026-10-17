extends RaytracedAudioPlayer3D
class_name  PlayerAudioPlayer







func play_player_sound(audio_stream: AudioStream, travel_distance: float, _vol: float = 0.0) -> void:
	stream = audio_stream
	volume_linear = _vol
	play()
	volume_linear = _vol
	# Emit the played sound signal halfway through the sound
	await get_tree().create_timer(audio_stream.get_length() * pitch_scale * 0.5).timeout
	PlayerBody.current_player_instance.played_sound.emit(
		global_position,
		travel_distance if PlayerBody.current_player_instance.has_hank_line_of_sight else travel_distance / 2,
	)
	prints(_vol, volume_linear)
