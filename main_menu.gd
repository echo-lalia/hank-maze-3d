extends Panel

@export var success_label: Label

@export var last_run_time_label: Label

@export var best_run_time_label: Label
@onready var last_run_root: MarginContainer = $LastRunRoot

@onready var best_run_root: MarginContainer = $BestRunRoot

const INIT_SCREEN_WAIT = preload("uid://nos2o78p06x2")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	last_run_time_label.text = Utils.seconds_to_timer(Main.game_stats["last_time"])
	best_run_time_label.text = Utils.seconds_to_timer(Main.game_stats["best_time"])
	
	if not Main.game_stats["has_finished_ever"]:
		last_run_root.queue_free()
	if not Main.game_stats["has_won_ever"]:
		best_run_root.queue_free()
	
	if Main.game_stats["won_last_game"]:
		if Main.game_stats["pb_last_time"]:
			success_label.text = "You won! (New best!)"
		else:
			success_label.text = "You won!"
	else:
		success_label.text = "You failed!"



func _on_play_button_pressed() -> void:
	add_child(INIT_SCREEN_WAIT.instantiate())
	await get_tree().process_frame
	await get_tree().physics_frame
	Main.start_game_run()
