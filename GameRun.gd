extends Node3D
class_name GameRun



signal won
signal lost




var run_start_time: float

func get_engine_time() -> float:
	return Time.get_ticks_usec() / 1e+6


func _ready() -> void:
	run_start_time = get_engine_time()


func get_run_time() -> float:
	return get_engine_time() - run_start_time




func win_game() -> void:
	won.emit()


func lose_game() -> void:
	lost.emit()
