extends VBoxContainer


@onready var brightness_value_label: Label = $FlowContainer/PanelContainer2/MarginContainer/HBoxContainer/PanelContainer/VBoxContainer/BrightnessValueLabel
@onready var volume_value_label: Label = $FlowContainer/PanelContainer3/MarginContainer/HBoxContainer/PanelContainer/VBoxContainer/VolumeValueLabel
@onready var fov_value_label: Label = $FlowContainer/PanelContainer/MarginContainer/HBoxContainer/PanelContainer/VBoxContainer/FOVValueLabel
@onready var mouse_speed_value_label: Label = $FlowContainer/PanelContainer4/MarginContainer/HBoxContainer/PanelContainer/VBoxContainer/MouseSpeedValueLabel

@onready var fovh_slider: HSlider = $FlowContainer/PanelContainer/MarginContainer/HBoxContainer/PanelContainer/VBoxContainer/FOVHSlider
@onready var brightness_h_slider: HSlider = $FlowContainer/PanelContainer2/MarginContainer/HBoxContainer/PanelContainer/VBoxContainer/BrightnessHSlider
@onready var volume_h_slider: HSlider = $FlowContainer/PanelContainer3/MarginContainer/HBoxContainer/PanelContainer/VBoxContainer/VolumeHSlider
@onready var mouse_speed_h_slider: HSlider = $FlowContainer/PanelContainer4/MarginContainer/HBoxContainer/PanelContainer/VBoxContainer/MouseSpeedHSlider



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fovh_slider.value = Main.game_save.fov
	brightness_h_slider.value = Main.game_save.brightness
	volume_h_slider.value = Main.game_save.volume
	update_labels()



func update_labels() -> void:
	fov_value_label.text = Utils.simple_format_number(Main.game_save.fov) + "°"
	brightness_value_label.text = Utils.simple_format_number(Main.game_save.brightness) + "%"
	volume_value_label.text = ("%+d" % Main.game_save.volume) + " dB"
	mouse_speed_value_label.text = str(int(Main.game_save.mouse_speed * 100)) + "%"



func _on_brightness_h_slider_value_changed(value: float) -> void:
	Main.game_save.brightness = value
	Main.notify_settings_changed()
	update_labels()



func _on_volume_h_slider_value_changed(value: float) -> void:
	Main.game_save.volume = value
	Main.notify_settings_changed()
	update_labels()



func _on_fovh_slider_value_changed(value: float) -> void:
	Main.game_save.fov = value
	Main.notify_settings_changed()
	update_labels()



func _on_mouse_speed_h_slider_value_changed(value: float) -> void:
	Main.game_save.mouse_speed = value
	Main.notify_settings_changed()
	update_labels()



func _slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Main.save_game()
