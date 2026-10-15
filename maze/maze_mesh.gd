@tool
extends Node3D
class_name MazeTileMesh


@onready var navigation_region_3d: NavigationRegion3D = $NavigationRegion3D


# WSEN
@export_flags("north:1", "east:2", "south:4", "west:8") var walls: int = 0:
	set(val):
		walls = val
		_build_walls()


#func bake_nav_mesh() -> void:
	#if not is_node_ready():
		#await ready
	#


func _make_single_wall() -> CSGBox3D:
		var result: CSGBox3D = CSGBox3D.new()
		result.size = Vector3(2.7, 2.5, 0.2)
		result.use_collision = true
		result.position.y = 1.25
		return result 


func _build_walls() -> void:
	if not is_node_ready():
		await ready
	
	# Clear old CSG walls
	for child in navigation_region_3d.get_children():
		if child is CSGBox3D:
			child.queue_free()
	
	# Make new CSG walls matching our flags.
	var wall: CSGBox3D
	if walls & 0b0001:
		wall = _make_single_wall()
		wall.position.z = -1.25
		navigation_region_3d.add_child(wall)
	if walls & 0b0100:
		wall = _make_single_wall()
		wall.position.z = 1.25
		navigation_region_3d.add_child(wall)
	if walls & 0b0010:
		wall = _make_single_wall()
		wall.rotation_degrees.y = 90
		wall.position.x = 1.25
		navigation_region_3d.add_child(wall)
	if walls & 0b1000:
		wall = _make_single_wall()
		wall.rotation_degrees.y = 90
		wall.position.x = -1.25
		navigation_region_3d.add_child(wall)
	
	
	navigation_region_3d.bake_navigation_mesh.call_deferred()
	
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	navigation_region_3d.navigation_mesh = navigation_region_3d.navigation_mesh.duplicate_deep()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
