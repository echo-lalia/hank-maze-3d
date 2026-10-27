extends Resource
class_name GameSave


const SAVE_PATH = "user://savedata.tres"


@export var best_run_time: float = 100_000_000_000.0
@export var last_run_time: float = 0.0
@export var pb_last_run: bool = false
@export var won_last_run: bool = false
@export var has_finished_run_ever: bool = false
@export var has_won_run_ever: bool = false

@export var fov: float = 75
@export var brightness: float = 100
@export var volume: float = 0


@export var sneak_button: InputEvent
@export var sprint_button: InputEvent
@export var hint_button: InputEvent
@export var bottle_button: InputEvent


static func load_save() -> GameSave:
	if FileAccess.file_exists(SAVE_PATH):
		print("Loading game data...")
		return load(SAVE_PATH)
	print("Couldn't load stored game data. Starting new save.")
	return GameSave.new()


func save() -> Error:
	#var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	return ResourceSaver.save(self, SAVE_PATH)



func _to_string() -> String:
	return (
		"GameSave:"
		+ "\n\tbest_run_time=" + str(best_run_time)
		+ "\n\tlast_run_time=" + str(last_run_time)
		+ "\n\tpb_last_run=" + str(pb_last_run)
		+ "\n\twon_last_run=" + str(won_last_run)
		+ "\n\thas_finished_run_ever=" + str(has_finished_run_ever)
		+ "\n\thas_won_run_ever=" + str(has_won_run_ever)
		+ "\n\tsneak_button=" + str(sneak_button)
		+ "\n\tsprint_button=" + str(sprint_button)
		+ "\n\thint_button=" + str(hint_button)
		+ "\n\tbottle_button=" + str(bottle_button)
	)
