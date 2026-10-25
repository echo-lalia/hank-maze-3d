extends Button
class_name RemapActionButton


var current_event: InputEvent
var waiting_for_input: bool = false


@export var game_save_event_name: StringName


func _init() -> void:
	toggle_mode = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	toggled.connect(_on_toggled)
	current_event = Main.game_save.get(game_save_event_name)
	set_label()


func set_label() -> void:
	if current_event:
		text = Utils.event_as_key_string(current_event)
	else:
		text = "UNBOUND"


func set_event(event: InputEvent) -> void:
	current_event = event
	waiting_for_input = false
	button_pressed = false
	set_label()
	Main.game_save.set(game_save_event_name, current_event)
	Main.setup_saved_input_events()
	Main.save_game()


func _input(event: InputEvent) -> void:
	if not waiting_for_input:
		return

	if event is InputEventKey or (event is InputEventMouseButton and event.pressed):
		# Dont allow escape or leftmouse button mappings (Escape keybinding)
		if InputMap.event_is_action(event, "escape"):
			# Escape/erase the given binding
			set_event(null)
		else:
			# Turn double into single click
			if event is InputEventMouseButton and event.double_click:
				event.double_click = false

			# Set a new binding
			set_event(event)
		accept_event()


func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		text = "Waiting..."
		waiting_for_input = true






#func init_event() -> void:
	#var events: Array[InputEvent] = InputMap.action_get_events(input_action)
	#current_event = events[0] if events else null
