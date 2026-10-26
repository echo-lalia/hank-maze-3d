extends ColorRect
class_name CreditsPanel




func _on_close_button_pressed() -> void:
	queue_free()



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		accept_event()
		queue_free()
