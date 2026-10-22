extends AudioStreamPlayer
class_name  PlayerAudioPlayer






func _calculate_travel_distance(travel_distance: float) -> float:
	if PlayerBody.current_player_instance.has_gourd:
		return travel_distance if PlayerBody.current_player_instance.has_hank_line_of_sight else travel_distance / 1.5
	return travel_distance if PlayerBody.current_player_instance.has_hank_line_of_sight else travel_distance / 2



#func play_player_sound(audio_stream: AudioStream, travel_distance: float, _vol: float = 0.0) -> void:
	#stream = audio_stream
	#volume_linear = _vol
	#play()
	## Emit the played sound signal halfway through the sound
	#await get_tree().create_timer(audio_stream.get_length() * pitch_scale * 0.5).timeout
	#PlayerBody.current_player_instance.played_sound.emit(
		#global_position,
		#_calculate_travel_distance(travel_distance),
	#)



func play_player_sound_from_position(pos: Vector3, audio_stream: AudioStream, travel_distance: float, _vol: float = 0.0) -> void:
	stream = audio_stream
	volume_db = _vol
	play()
	# Emit the played sound signal halfway through the sound
	await get_tree().create_timer(audio_stream.get_length() * pitch_scale * 0.5).timeout
	PlayerBody.current_player_instance.played_sound.emit(
		pos,
		_calculate_travel_distance(travel_distance),
	)
