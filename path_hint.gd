extends Node3D
class_name PathHint



const HINT_LENGTH = 10.0
const HINT_POINT_DISTANCE = 0.1
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var cpu_particles_3d: CPUParticles3D = $CPUParticles3D

@export var maze_generator: MazeWallGenerator

var reverse_path_flow: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	await get_tree().physics_frame
	navigation_agent_3d.target_position = (
		maze_generator.start_room_position.global_position
		if PlayerBody.current_player_instance.has_gourd else
		maze_generator.end_room_position.global_position
	)
	if PlayerBody.current_player_instance.has_gourd:
		reverse_path_flow = true
	navigation_agent_3d.get_next_path_position() # Might be required to update pathing. Try with and without maybe?
	await get_tree().physics_frame
	_setup_path()


func _setup_path() -> void:
	var navigation_path: PackedVector3Array = navigation_agent_3d.get_current_navigation_path()
	
	# We need an array of points denoting the current path, up to the hint length.
	var hint_points: Array[Vector3] = [navigation_path[0]]
	var current_total_distance: float = 0.0
	for i in range(1, len(navigation_path)):
		var point_dist: float = navigation_path[i-1].distance_to(navigation_path[i])
		if current_total_distance + point_dist < HINT_LENGTH:
			hint_points.append(navigation_path[i])
			current_total_distance += point_dist
		else:
			# This is the final point in the hint path, and it needs to be trimmed to length.
			var direction: Vector3 = (navigation_path[i] - navigation_path[i-1]).normalized()
			var required_dist: float = HINT_LENGTH - current_total_distance
			hint_points.append(navigation_path[i-1] + direction*required_dist)
			break
	
	# The hint points will have big breaks in them, so we have to resample.
	var resampled_points: Array[Vector3] = [hint_points[0]]
	for i in range(1, len(hint_points)):
		var prev_point: Vector3 = hint_points[i - 1]
		var current_point: Vector3 = hint_points[i]
		var point_dist: float = current_point.distance_to(prev_point)
		
		
		if point_dist > HINT_POINT_DISTANCE:
			var num_points: int = int(point_dist / HINT_POINT_DISTANCE)
			for sample_idx in num_points:
				resampled_points.append(prev_point.lerp(current_point, float(sample_idx) / num_points))
		
		resampled_points.append(current_point)
	
	# Convert the resampled points into local coordinates (which are what the particles use)
	for i in len(resampled_points):
		resampled_points[i] = to_local(resampled_points[i])
	
	# Calculate flow direction (particle point normals) for each point.
	var point_normals: Array[Vector3] = []
	for i in range(0, len(resampled_points) - 1):
		point_normals.append((resampled_points[i + 1] - resampled_points[i]).normalized())
	if point_normals:
		point_normals.append(point_normals[-1])
	
	
	cpu_particles_3d.emission_points = PackedVector3Array(resampled_points)
	cpu_particles_3d.emission_normals = PackedVector3Array(point_normals)
	
