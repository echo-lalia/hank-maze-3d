extends SubViewport


@export var player: PlayerBody


@onready var needle: Node3D = $Compass/Needle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#player.global_position.angle_to()
	#player.head_rotation.y
	#needle.look_at(player.maze_generator.end_room_position.global_position)
	var offset: Vector3 = player.maze_generator.end_room_position.global_position - player.global_position
	var new_rotation: float = Vector3.FORWARD.signed_angle_to(offset.normalized(), Vector3(0, 1, 0)) - player.player_head.global_rotation.y
	needle.rotation.y = lerp_angle(needle.rotation.y, new_rotation, 2 * delta)
