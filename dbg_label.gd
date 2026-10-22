extends Label
class_name DebugLabel



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	text = (
		"sees_player=" + str(HankAlpeca.current_hank_mesh_instance.sees_player)
		+ "\nhas_hank_line_of_sight=" + str(PlayerBody.current_player_instance.has_hank_line_of_sight)
	)
	if Input.is_action_just_pressed("dbg_label"):
		visible = not visible
