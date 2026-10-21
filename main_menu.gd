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

	last_run_time_label.text = Utils.seconds_to_timer(Main.game_save.last_run_time)
	best_run_time_label.text = Utils.seconds_to_timer(Main.game_save.best_run_time)
	
	if not Main.game_save.has_finished_run_ever:
		last_run_root.queue_free()
	if not Main.game_save.has_won_run_ever:
		best_run_root.queue_free()
	
	if Main.game_save.won_last_run:
		if Main.game_save.pb_last_run:
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
