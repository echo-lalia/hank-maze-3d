extends Node
class_name Main


const SAVE_PATH = "user://hankattackdata"

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
	load_stats()
	start_main_menu()



static var game_stats: Dictionary[String, Variant] = {
	"best_time": 100_000_000_000.0,
	"last_time": 0.0,
	"pb_last_time": false,
	"won_last_game": false,
	"has_finished_ever": false,
	"has_won_ever": false,
}




static func load_stats() -> void:
	print("Loading game data...")
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		print("Couldn't load stored game data; got '%'.\nStarting new save." % error_string(FileAccess.get_open_error()))
		return
	
	var loaded = file.get_var()
	if loaded is Dictionary:
		game_stats.merge(loaded, true)
		print("Loaded game data!")
	else:
		print("Loaded data wasn't the expected format. Loaded: ", loaded)


static func save_stats() -> void:
	print("Saving stats...")
	print(game_stats)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Couldn't create save data; got '%'." % error_string(FileAccess.get_open_error()))
		return
	
	var is_ok: bool = file.store_var(game_stats)
	
	if not is_ok:
		push_error("Couldn't save game data; got '%'." % error_string(FileAccess.get_open_error()))
	
