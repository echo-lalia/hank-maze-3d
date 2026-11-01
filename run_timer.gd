extends MarginContainer



const HARD_MODE_THEME = preload("uid://d3cy7i0amx47t")


@onready var time_label: RunTimeLabel = $TimeLabel


func _ready() -> void:
	if not Main.game_save.has_won_run_ever:
		queue_free()
	if GameRun.current_game_run.hard_mode:
		theme = HARD_MODE_THEME
		
		var hard_mode_label_clr: Color = HARD_MODE_THEME.get_color("font_color", "Label")
		var hard_mode_label_shadow: Color = HARD_MODE_THEME.get_color("font_shadow_color", "Label")
		time_label.label_settings = time_label.label_settings.duplicate()
		time_label.label_settings.font_color = hard_mode_label_clr
		time_label.label_settings.shadow_color = hard_mode_label_shadow


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	time_label.time = GameRun.current_game_run.get_run_time()
