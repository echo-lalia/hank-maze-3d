extends MarginContainer


@onready var time_label: RunTimeLabel = $TimeLabel


func _ready() -> void:
	if not Main.game_save.has_won_run_ever:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	time_label.time = GameRun.current_game_run.get_run_time()
