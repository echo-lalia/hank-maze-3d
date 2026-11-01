extends Panel


const HARD_MODE_THEME = preload("uid://d3cy7i0amx47t")


@export var success_label: Label

@export var last_run_time_label: RunTimeLabel

@export var best_run_time_label: RunTimeLabel
@export var last_run_root: MarginContainer
@export var hard_mode_color_override_labels: Array[Label] = []


#@export var best_run_root: MarginContainer
#@export var hard_mode_button: Button


@export var delete_if_not_beaten_run: Array[Control] = []
@export var delete_if_not_beaten_hard_mode: Array[Control] = []



const INIT_SCREEN_WAIT = preload("uid://nos2o78p06x2")
const CREDITS = preload("uid://eitkhjbnlx05")


@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	Utils.animate(audio_stream_player, "volume_db", -80, -20, 0.5)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	last_run_time_label.time = Main.game_save.last_run_time
	best_run_time_label.time = Main.game_save.best_run_time
	
	
	if Main.game_save.last_run_was_hard_mode:
		last_run_root.theme = HARD_MODE_THEME
		var hard_mode_label_clr: Color = HARD_MODE_THEME.get_color("font_color", "Label")
		var hard_mode_label_shadow: Color = HARD_MODE_THEME.get_color("font_shadow_color", "Label")
		for label in hard_mode_color_override_labels:
			if label.label_settings:
				label.label_settings = label.label_settings.duplicate()
				label.label_settings.font_color = hard_mode_label_clr
				label.label_settings.shadow_color = hard_mode_label_shadow
	
	
	if not Main.game_save.has_finished_run_ever:
		last_run_root.queue_free()
	if not Main.game_save.has_won_run_ever:
		for element in delete_if_not_beaten_run:
			if element:
				element.queue_free()
		#best_run_root.queue_free()
		#hard_mode_button.queue_free()
	
	if not Main.game_save.has_won_hard_mode_ever:
		for element in delete_if_not_beaten_hard_mode:
			if element:
				element.queue_free()
	
	
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


func _on_hard_mode_button_pressed() -> void:
	var init_screen: InitScreen = INIT_SCREEN_WAIT.instantiate()
	Main.current_main_instance.add_child(init_screen)
	await init_screen.finished_initializing
	await get_tree().process_frame
	await get_tree().physics_frame
	Main.start_hard_mode_run()


func _on_credits_button_pressed() -> void:
	add_child(CREDITS.instantiate())


func _on_exit_button_pressed() -> void:
	get_tree().quit()
