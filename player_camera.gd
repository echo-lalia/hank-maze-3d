extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Main.current_main_instance.settings_changed.connect(_on_settings_changed)
	pass # Replace with function body.

func _on_settings_changed() -> void:
	fov = Main.game_save.fov
	
