extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resume()
	
	get_window().focus_entered.connect(_on_focus_entered)
	get_window().focus_exited.connect(_on_focus_exited)



func _on_focus_entered() -> void:
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func _on_focus_exited() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE



func pause() -> void:
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func resume() -> void:
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		if visible:
			resume()
		else:
			pause()



func _on_resume_button_pressed() -> void:
	resume()


func _on_quit_button_pressed() -> void:
	resume()
	Main.start_main_menu()
