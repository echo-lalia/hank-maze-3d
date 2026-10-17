extends StateMachine
class_name HankStateMachine


@export var hank_body: HankBody
@export var hank_mesh: HankAlpeca

func _ready() -> void:
	if not hank_body.is_node_ready():
		await ready
	super()
