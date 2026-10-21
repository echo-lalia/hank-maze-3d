extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Main.current_main_instance.settings_changed.connect(_on_settings_changed)
	_on_settings_changed()


func _on_settings_changed() -> void:
	fov = Main.game_save.fov
	environment.adjustment_brightness = Main.game_save.brightness / 100.0
	environment.ambient_light_energy = Utils.map_range(Main.game_save.brightness, 50, 200, 0.08, 0.3)
