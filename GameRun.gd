extends Node3D
class_name GameRun



signal won
signal lost




var run_start_time_us: int
func _ready() -> void:
	run_start_time_us = Time.get_ticks_usec()


func get_run_time_us() -> float:
	return Time.get_ticks_usec() - run_start_time_us




func win_game() -> void:
	won.emit()


func lose_game() -> void:
	lost.emit()
