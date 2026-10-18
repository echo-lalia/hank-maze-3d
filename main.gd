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
	start_main_menu()
