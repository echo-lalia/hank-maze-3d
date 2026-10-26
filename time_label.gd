@tool
extends Label
class_name RunTimeLabel



@export var ms_label: Label


@export var time: float = 0.0:
	set(val):
		time = val
		_update_time()



func _update_time() -> void:
	if not is_node_ready():
		await ready
	var m_s_ms := Utils.seconds_to_m_s_ms(time)
	text = str(m_s_ms[0]) + ":" + str(m_s_ms[1]) + "      "
	ms_label.text = "." + str(m_s_ms[2]).lpad(3, "0")
