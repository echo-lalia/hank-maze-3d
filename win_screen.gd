extends Node3D

@onready var gourd_mesh: MeshInstance3D = $GourdMesh
@onready var you_won_label: Label = $Camera3D/YouWonLabel
@onready var run_time_label: Label = $Camera3D/RunTimeLabel
@onready var new_pb_label: Label = $Camera3D/RunTimeLabel/NewPBLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var door_sound_player: AudioStreamPlayer = $DoorSoundPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	run_time_label.text = "Time: " + Utils.seconds_to_timer(Main.game_save.last_run_time)
	if not Main.game_save.pb_last_run:
		new_pb_label.text = ""
	
	var gourd_spin_tween: Tween = create_tween()
	gourd_spin_tween.set_loops()
	gourd_spin_tween.tween_property(gourd_mesh, "rotation:y", deg_to_rad(0), 0)
	gourd_spin_tween.tween_property(gourd_mesh, "rotation:y", deg_to_rad(360), 6.66 * 3)
	
	audio_stream_player.finished.connect(_return_to_menu)
	
	
	# Allow skipping the win screen, but prevent accidentally skipping.
	set_process_input(false)
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	set_process_input(true)




func _return_to_menu() -> void:
	Main.start_main_menu()



func _input(event: InputEvent) -> void:
	if event.is_action("skip_scene"):
		_return_to_menu()
