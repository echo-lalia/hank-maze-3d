extends NavigationRegion3D
class_name MazeWallGenerator




const MAZE_LENGTH = 20
const MAZE_RADIUS = 5
const MAZE_WIDTH = MAZE_RADIUS*2 + 1


const ROOM_SIZE: float = 4
const WALL_THICKNESS: float = 0.2
const ROOM_SIZE_HALF: float = ROOM_SIZE / 2.0
const MAZE_X_OFFSET: float = MAZE_WIDTH * ROOM_SIZE * 0.5 - ROOM_SIZE_HALF


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_maze()
	
	var floor: MeshInstance3D = MeshInstance3D.new()
	var floor_shape: QuadMesh = QuadMesh.new()
	floor_shape.size = Vector2(MAZE_WIDTH * ROOM_SIZE, ROOM_SIZE * MAZE_LENGTH)
	floor_shape.orientation = PlaneMesh.FACE_Y
	floor.mesh = floor_shape
	floor.position = Vector3(0, 0, ROOM_SIZE * MAZE_LENGTH * 0.5 - ROOM_SIZE_HALF)
	add_child(floor)
	
	await get_tree().process_frame
	bake_navigation_mesh()
	await bake_finished


func _make_single_wall() -> CSGBox3D:
		var result: CSGBox3D = CSGBox3D.new()
		result.size = Vector3(ROOM_SIZE + WALL_THICKNESS, ROOM_SIZE, WALL_THICKNESS)
		result.use_collision = true
		result.position.y = ROOM_SIZE_HALF
		return result 


func generate_maze() -> void:
	var maze: MazeSquare.Shape = MazeSquare.Shape.new(MAZE_WIDTH, MAZE_LENGTH)
	
	MazeAlgoRecursiveBacktracker.generate(maze, maze.room(MAZE_RADIUS, 0))
	
	
	for y in MAZE_LENGTH:
		for x in MAZE_WIDTH:
			var room_position: Vector3 = Vector3(x * ROOM_SIZE - MAZE_X_OFFSET, 0, y * ROOM_SIZE)
			var room: MazeSquare.Room = maze.room(x, y)
			var wall_bits: int = room.walls_id()
			
			# In order to only make one wall per wall, only create N/W walls
			# except for when we reach the eastmost or southmost tiles.
			var wall: CSGBox3D
			# WSEN
			if wall_bits & 0b0001:  # N
				wall = _make_single_wall()
				wall.position += room_position + Vector3(0, 0, -ROOM_SIZE_HALF)
				add_child(wall)
			if wall_bits & 0b1000:  # W
				wall = _make_single_wall()
				wall.rotation_degrees.y = 90
				wall.position += room_position + Vector3(-ROOM_SIZE_HALF, 0, 0)
				add_child(wall)
			if (y == MAZE_LENGTH - 1) and (wall_bits & 0b0100):  # S
				wall = _make_single_wall()
				wall.position += room_position + Vector3(0, 0, ROOM_SIZE_HALF)
				add_child(wall)
			if (x == MAZE_WIDTH - 1) and (wall_bits & 0b0010):  # E
				wall = _make_single_wall()
				wall.rotation_degrees.y = 90
				wall.position += room_position + Vector3(ROOM_SIZE_HALF, 0, 0)
				add_child(wall)
