extends Panel

@export var success_label: Label

@export var last_run_time_label: RunTimeLabel

@export var best_run_time_label: RunTimeLabel
@export var last_run_root: MarginContainer

@export var best_run_root: MarginContainer

const INIT_SCREEN_WAIT = preload("uid://nos2o78p06x2")
const CREDITS = preload("uid://eitkhjbnlx05")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	last_run_time_label.time = Main.game_save.last_run_time
	best_run_time_label.time = Main.game_save.best_run_time
	
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
	var init_screen: InitScreen = INIT_SCREEN_WAIT.instantiate()
	Main.current_main_instance.add_child(init_screen)
	await init_screen.finished_initializing
	await get_tree().process_frame
	await get_tree().physics_frame
	Main.start_game_run()


func _on_credits_button_pressed() -> void:
	add_child(CREDITS.instantiate())


func _on_exit_button_pressed() -> void:
	get_tree().quit()
