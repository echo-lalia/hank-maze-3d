extends Node
class_name Main



const MAIN_MENU = preload("uid://crs3ct2mo8vgb")
const GAME_RUN = preload("uid://c3xba446ythyp")
const HANKDEATHSCREEN = preload("uid://d1ynnc2lyyb5y")



static var created_instance: Node
static var current_main_instance: Main


static func delete_created_instance() -> void:
	if created_instance:
		created_instance.queue_free()



static func start_scene(scene: PackedScene) -> void:
	delete_created_instance()
	created_instance = scene.instantiate()
	current_main_instance.add_child(created_instance)


static func start_game_run() -> void:
	start_scene(GAME_RUN)


static func start_main_menu() -> void:
	start_scene(MAIN_MENU)


static func start_hank_death_screen() -> void:
	start_scene(HANKDEATHSCREEN)



func _init() -> void:
	current_main_instance = self


func _ready() -> void:
	load_game()
	start_main_menu()






static var game_save: GameSave

signal settings_changed



static func notify_settings_changed() -> void:
	current_main_instance.settings_changed.emit()


static func setup_saved_input_events() -> void:
	if game_save.sneak_button:
		InputMap.action_erase_events("sneak")
		InputMap.action_add_event("sneak", game_save.sneak_button)
	else:
		var events: Array[InputEvent] = InputMap.action_get_events("sneak")
		if events:
			game_save.sneak_button = events[0]
	if game_save.sprint_button:
		InputMap.action_erase_events("sprint")
		InputMap.action_add_event("sprint", game_save.sprint_button)
	else:
		var events: Array[InputEvent] = InputMap.action_get_events("sprint")
		if events:
			game_save.sprint_button = events[0]
	notify_settings_changed()



static func load_game() -> void:
	print("Loading game data...")
	game_save = GameSave.load_save()
	setup_saved_input_events()
	print("Loaded: ")
	print(game_save)


static func save_game() -> void:
	print("Saving game data...")
	print(game_save)
	var err: Error = game_save.save()
	if err == OK:
		print("Saved!")
	else:
		push_error("Couldn't save game data: " + error_string(err))
	
