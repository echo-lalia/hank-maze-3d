extends Node
class_name Main



const MAIN_MENU = preload("uid://crs3ct2mo8vgb")
const GAME_RUN = preload("uid://c3xba446ythyp")
const HANKDEATHSCREEN = preload("uid://d1ynnc2lyyb5y")
const WIN_SCREEN = preload("uid://cxct4crj3ig0c")



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


static func start_win_screen() -> void:
	start_scene(WIN_SCREEN)


func _init() -> void:
	current_main_instance = self




func _ready() -> void:
	load_game()
	start_main_menu()
	settings_changed.connect(_on_settings_changed)
	_on_settings_changed()
	get_viewport().size_changed.connect(_viewport_size_changed)
	_viewport_size_changed()



func _viewport_size_changed() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	RenderingServer.global_shader_parameter_set("viewport_width_beyer", viewport_size.x / 8)
	RenderingServer.global_shader_parameter_set("viewport_height_beyer", viewport_size.y / 8)





static var game_save: GameSave

signal settings_changed



static func set_main_volume(vol: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), vol)



func _on_settings_changed() -> void:
	set_main_volume(game_save.volume)


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
	if game_save.hint_button:
		InputMap.action_erase_events("hint")
		InputMap.action_add_event("hint", game_save.hint_button)
	else:
		var events: Array[InputEvent] = InputMap.action_get_events("hint")
		if events:
			game_save.hint_button = events[0]
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
	
