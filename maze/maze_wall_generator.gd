extends NavigationRegion3D
class_name MazeWallGenerator

const VAULTABLE_WALL = preload("uid://xrikcftunle")

const EMPTY_WALL_THRESHOLD = 0.1
const VAULT_CHANCE_THRESHOLD = 0.1

const MAZE_LENGTH = 20
const MAZE_RADIUS = 5
const MAZE_WIDTH = MAZE_RADIUS*2 + 1


const ROOM_SIZE: float = 6
const ROOM_HEIGHT: float = 4
const WALL_THICKNESS: float = 0.2
const ROOM_SIZE_HALF: float = ROOM_SIZE / 2.0
const MAZE_X_OFFSET: float = MAZE_WIDTH * ROOM_SIZE * 0.5 - ROOM_SIZE_HALF


@export_flags_3d_physics var wall_collision: int = 0b1001


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_maze()
	
	var floor_instance: MeshInstance3D = MeshInstance3D.new()
	var floor_shape: QuadMesh = QuadMesh.new()
	floor_shape.size = Vector2(MAZE_WIDTH * ROOM_SIZE, ROOM_SIZE * MAZE_LENGTH)
	floor_shape.orientation = PlaneMesh.FACE_Y
	floor_instance.mesh = floor_shape
	floor_instance.position = Vector3(0, 0, ROOM_SIZE * MAZE_LENGTH * 0.5 - ROOM_SIZE_HALF)
	add_child(floor_instance)
	
	# Not sure if this is needed, but I want to be sure the CSG meshes have been generated.
	await get_tree().process_frame
	bake_navigation_mesh()
	await bake_finished


func _make_single_wall(allow_special: bool = true) -> Node3D:
	# Chance for a special wall.
	if allow_special:
		var special_rand: float = randf()
		if special_rand < EMPTY_WALL_THRESHOLD:
			return null
		elif special_rand < (EMPTY_WALL_THRESHOLD + VAULT_CHANCE_THRESHOLD):
			var wall: VaultableWall = VAULTABLE_WALL.instantiate()
			wall.width = ROOM_SIZE
			wall.height = ROOM_HEIGHT
			wall.thickness = WALL_THICKNESS
			return wall

	var result: CSGBox3D = CSGBox3D.new()
	result.size = Vector3(ROOM_SIZE + WALL_THICKNESS, ROOM_HEIGHT, WALL_THICKNESS)
	result.use_collision = true
	result.collision_layer = wall_collision
	result.collision_mask = wall_collision
	result.position.y = ROOM_HEIGHT * 0.5
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
			var wall: Node3D
			# WSEN
			if wall_bits & 0b0001:  # N
				wall = _make_single_wall(y != 0)
				if wall:
					wall.position += room_position + Vector3(0, 0, -ROOM_SIZE_HALF)
					add_child(wall)
			if wall_bits & 0b1000:  # W
				wall = _make_single_wall(x != 0)
				if wall:
					wall.rotation_degrees.y = 90
					wall.position += room_position + Vector3(-ROOM_SIZE_HALF, 0, 0)
					add_child(wall)
			if (y == MAZE_LENGTH - 1) and (wall_bits & 0b0100):  # S
				wall = _make_single_wall(false)
				wall.position += room_position + Vector3(0, 0, ROOM_SIZE_HALF)
				add_child(wall)
			if (x == MAZE_WIDTH - 1) and (wall_bits & 0b0010):  # E
				wall = _make_single_wall(false)
				wall.rotation_degrees.y = 90
				wall.position += room_position + Vector3(ROOM_SIZE_HALF, 0, 0)
				add_child(wall)
