extends NavigationRegion3D
class_name MazeWallGenerator

const VAULTABLE_WALL = preload("uid://xrikcftunle")
const WALL_SHADER = preload("uid://ctxrr6hfuxpr")
const FLOOR_MATERIAL = preload("uid://de54k6p86uv8r")
const CEILING_MATERIAL = preload("uid://cpmqma4scpyea")

const BIG_ROOM_CHANCE = 0.25
const VAULT_CHANCE_THRESHOLD = 0.1
const CHANCE_TO_DELETE_WALL_ENDS = 0.5

const BANANATHING = preload("uid://detsxsphpkx4q")
const CEILINGLIGHT = preload("uid://23hbjy7d64p4")
const BARREL = preload("uid://bnptm6smf1frh")
const CEILING_SPEAKER = preload("uid://318qjienj8by")
const COMPASS_ITEM = preload("uid://bj8eiy7kqdsw")

const CEILING_LIGHT_CHANCE: float = 0.02

const MAZE_LENGTH = 20
const MAZE_RADIUS = 5
const MAZE_WIDTH = MAZE_RADIUS*2 + 1


const ROOM_SIZE: float = 6
const ROOM_HEIGHT: float = 4
const WALL_THICKNESS: float = 0.2
const ROOM_SIZE_HALF: float = ROOM_SIZE / 2.0
const MAZE_X_OFFSET: float = MAZE_WIDTH * ROOM_SIZE * 0.5 - ROOM_SIZE_HALF

# WSEN
const NORTH: int = 0b0001
const EAST: int = 0b0010
const SOUTH: int = 0b0100
const WEST: int = 0b1000

## Room coordinates that can't generate objects
const BANNED_OBJECT_ROOMS: Array[Array] = [[MAZE_RADIUS, 0], [MAZE_RADIUS, MAZE_LENGTH-1]]


@onready var csg_combiner_3d: CSGCombiner3D = $CSGCombiner3D

@export_flags_3d_physics var wall_collision: int = 0b1001

@onready var start_room_position: Node3D = $StartRoomPosition
@onready var end_room_position: Node3D = $EndRoomPosition
@onready var hank_room_position: Node3D = $HankRoomPosition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_maze()
	
	var floor_instance: MeshInstance3D = MeshInstance3D.new()
	var floor_shape: QuadMesh = QuadMesh.new()
	floor_shape.size = Vector2(MAZE_WIDTH * ROOM_SIZE, ROOM_SIZE * MAZE_LENGTH)
	floor_shape.orientation = PlaneMesh.FACE_Y
	floor_instance.mesh = floor_shape
	floor_instance.position = Vector3(0, 0, ROOM_SIZE * MAZE_LENGTH * 0.5 - ROOM_SIZE_HALF)
	floor_shape.material = FLOOR_MATERIAL
	add_child(floor_instance)
	
	var ceiling_instance: MeshInstance3D = MeshInstance3D.new()
	ceiling_instance.mesh = floor_shape.duplicate_deep()
	ceiling_instance.mesh.material = CEILING_MATERIAL
	ceiling_instance.mesh.flip_faces = true
	ceiling_instance.position = Vector3(0, 6.1, ROOM_SIZE * MAZE_LENGTH * 0.5 - ROOM_SIZE_HALF)
	add_child(ceiling_instance)
	
	start_room_position.global_position = global_position + room_coord_to_relative_position(MAZE_RADIUS, 0)
	end_room_position.global_position = global_position + room_coord_to_relative_position(MAZE_RADIUS, MAZE_LENGTH - 1)
	@warning_ignore("integer_division")
	hank_room_position.global_position = global_position + room_coord_to_relative_position(MAZE_RADIUS, MAZE_LENGTH/2)
	
	# Not sure if this is needed, but I want to be sure the CSG meshes have been generated.
	await get_tree().process_frame
	bake_navigation_mesh()
	await bake_finished
	
	# Add compass item to maze
	var compass_item: Node3D = COMPASS_ITEM.instantiate()
	compass_item.position = room_coord_to_relative_position(randi_range(0, MAZE_WIDTH), randi_range(int(MAZE_LENGTH * 0.333), int(MAZE_LENGTH * 0.666)))
	add_child(compass_item)
	
	#var probe := create_reflection_probe(Vector3((MAZE_WIDTH + 2) * ROOM_SIZE, ROOM_HEIGHT * 3, ROOM_SIZE * (MAZE_LENGTH + 2)))
	#probe.global_position = hank_room_position.global_position
	#add_child(probe)



func create_reflection_probe(size: Vector3) -> ReflectionProbe:
	var reflection_probe: ReflectionProbe = ReflectionProbe.new()
	reflection_probe.size = size
	reflection_probe.box_projection = true
	reflection_probe.interior = true
	reflection_probe.enable_shadows = true
	return reflection_probe


func _make_single_wall(allow_special: bool = true) -> Node3D:
	# Chance for a special wall.
	if allow_special:
		var special_rand: float = randf()
		if special_rand < VAULT_CHANCE_THRESHOLD:
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
	result.material = WALL_SHADER
	return result 



func _test_wall_exists(maze: MazeSquare.Shape, x: int, y: int, wall: int) -> bool:
	return maze.room(x, y).walls_id() & wall


## Maps a room's walls with the neighboring walls to test/count.
static var _CONNECTED_WALL_MAP: Dictionary[int, Array] = {
	NORTH: [
		[0, -1, WEST], [0, -1, EAST],
		[-1, 0, NORTH], [1, 0, NORTH],
		[0, 0, WEST], [0, 0, EAST],
	],
	EAST: [
		[0, 0, NORTH], [0, 0, SOUTH],
		[0, 1, EAST], [0, -1, EAST],
		[1, 0, NORTH], [1, 0, SOUTH],
	],
	SOUTH: [
		[0, 0, WEST], [0, 0, EAST],
		[-1, 0, SOUTH], [1, 0, SOUTH],
		[0, 1, WEST], [0, 1, EAST],
	],
	WEST: [
		[0, 0, NORTH], [0, 0, SOUTH],
		[0, 1, WEST], [0, -1, WEST],
		[-1, 0, NORTH], [-1, 0, SOUTH],
	],
}
func _count_maze_wall_connections(maze: MazeSquare.Shape, x: int, y: int, wall: int) -> int:
	var result: int = 0

	var test_map: Array = _CONNECTED_WALL_MAP[wall]
	for tst in test_map:
		var tx: int = x + tst[0]
		var ty: int = y + tst[1]
		var twall: int = tst[2]
		if (0 <= tx and tx < MAZE_WIDTH) and (0 <= ty and ty < MAZE_LENGTH) \
		and maze.room(tx, ty).walls_id() & twall:
			result += 1
	
	return result


## Maps a room's walls with the neighboring walls to test/count, grouped by side (arbitrary order).
static var _END_WALL_MAP: Dictionary[int, Array] = {
	NORTH: [
		[[0, -1, WEST], [-1, 0, NORTH], [0, 0, WEST]],   # west end
		[[0, -1, EAST], [1, 0, NORTH], [0, 0, EAST]],    # east end
	],
	EAST: [
		[[0, 0, NORTH], [0, -1, EAST], [1, 0, NORTH]],   # north end
		[[0, 0, SOUTH], [0, 1, EAST], [1, 0, SOUTH]],    # south end
	],
	SOUTH: [
		[[0, 0, WEST], [-1, 0, SOUTH], [0, 1, WEST]],    # west end
		[[0, 0, EAST], [1, 0, SOUTH], [0, 1, EAST]],     # east end
	],
	WEST: [
		[[0, 0, NORTH], [0, -1, WEST], [-1, 0, NORTH]],  # north end
		[[0, 0, SOUTH], [0, 1, WEST], [-1, 0, SOUTH]],   # south end
	],
}
## Check if a wall has connections on each side, return 0, 1, or 2 for number of sides connected.
func _wall_sides_with_connections(maze: MazeSquare.Shape, x: int, y: int, wall: int) -> int:
	var connections: int = 0

	var test_map: Array = _END_WALL_MAP[wall]
	for side in test_map:
		for tst in side:
			var tx: int = x + tst[0]
			var ty: int = y + tst[1]
			var twall: int = tst[2]
			if (0 <= tx and tx < MAZE_WIDTH) and (0 <= ty and ty < MAZE_LENGTH) \
			and maze.room(tx, ty).walls_id() & twall:
				connections += 1
				break
	
	return connections


## Connect the given room to the rooms to the east and south (those rooms MUST exist, or this will error).
func _connect_room_square(maze: MazeSquare.Shape, x: int, y: int) -> void:
	var room: MazeSquare.Room = maze.room(x, y)
	room.open_wall_between(maze.room(x + 1, y))
	room.open_wall_between(maze.room(x, y + 1))
	var corner_room: MazeSquare.Room = maze.room(x + 1, y + 1)
	corner_room.open_wall_between(maze.room(x + 1, y))
	corner_room.open_wall_between(maze.room(x, y + 1))
	

func _dbg_label_wall_connections(wall: Node3D, maze: MazeSquare.Shape, x: int, y: int, wallid: int) -> void:
	var label: Label3D = Label3D.new()
	label.text = str(_wall_sides_with_connections(maze, x, y, wallid))
	wall.add_child(label)
	label.position.y += 5



func room_coord_to_relative_position(x: int, y: int) -> Vector3:
	return Vector3(x * ROOM_SIZE - MAZE_X_OFFSET, 0, y * ROOM_SIZE)



func _random_room_position(margin: float = 1.0) -> Vector3:
	return Vector3(
		randf_range(-ROOM_SIZE_HALF + margin, ROOM_SIZE_HALF - margin),
		0,
		randf_range(-ROOM_SIZE_HALF + margin, ROOM_SIZE_HALF - margin),
	)

func add_objects_to_room(room_position: Vector3) -> void:
	var objects_to_add: int = randi_range(0, 1)
	var rand_objects: Array[PackedScene] = [BANANATHING, BARREL, CEILING_SPEAKER]
	for i in objects_to_add:
		var rand_obj: PackedScene = rand_objects.pick_random()
		var item: Node3D
		match rand_obj:
			BANANATHING:
				item = BANANATHING.instantiate()
				# Add to a random position with a random rotation.
				item.position = room_position + _random_room_position(0.8)
				item.rotation.y = randf_range(0, deg_to_rad(360))
				add_child(item)
			BARREL:
				item = BARREL.instantiate()
				# Add to a random position with a random rotation.
				item.position = room_position + _random_room_position(0.8)
				item.rotation.y = randf_range(0, deg_to_rad(360))
				add_child(item)
			CEILING_SPEAKER:
				item = CEILING_SPEAKER.instantiate()
				# Add to a random position with a random rotation.
				item.position = room_position + _random_room_position(0.8)
				add_child(item)
	
	@warning_ignore("integer_division")
	if randf() < CEILING_LIGHT_CHANCE \
	or room_coord_to_relative_position(MAZE_RADIUS, 0).is_equal_approx(room_position) \
	or room_coord_to_relative_position(MAZE_RADIUS, MAZE_LENGTH/2).is_equal_approx(room_position):
			var item: Node3D = CEILINGLIGHT.instantiate()
			item.position = room_position
			add_child(item)




func generate_maze() -> void:
	var maze: MazeSquare.Shape = MazeSquare.Shape.new(MAZE_WIDTH, MAZE_LENGTH)
	
	
	
	# Open some random walls before generating the maze
	for i in 2:
		var x := randi_range(0, MAZE_WIDTH - 2)
		var y := randi_range(0, MAZE_LENGTH - 2)
		_connect_room_square(maze, x, y)
		
		var wide: bool = (x < MAZE_WIDTH - 3) and (randf() < BIG_ROOM_CHANCE)
		var tall: bool = (y < MAZE_LENGTH - 3) and (randf() < BIG_ROOM_CHANCE)
		if wide:
			_connect_room_square(maze, x + 1, y)
		if tall:
			_connect_room_square(maze, x, y + 1)
		if wide and tall:
			_connect_room_square(maze, x + 1, y + 1)
	
	MazeAlgoRecursiveBacktracker.generate(maze, maze.room(MAZE_RADIUS, 0))
	
	
	for y in MAZE_LENGTH:
		for x in MAZE_WIDTH:
			var room_position: Vector3 = room_coord_to_relative_position(x, y)
			var room: MazeSquare.Room = maze.room(x, y)
			
			if [x, y] not in BANNED_OBJECT_ROOMS:
				add_objects_to_room(room_position)
			
			var wall_bits: int = room.walls_id()
			
			# In order to only make one wall per wall, only create N/W walls
			# except for when we reach the eastmost or southmost tiles.
			var wall: Node3D
			# WSEN
			if wall_bits & NORTH:  # N
				var delete_wall_end: bool = (_wall_sides_with_connections(maze, x, y, NORTH) <= 1) and (randf() < CHANCE_TO_DELETE_WALL_ENDS)
				if not delete_wall_end:
					wall = _make_single_wall(y != 0)
					wall.position += room_position + Vector3(0, 0, -ROOM_SIZE_HALF)
					csg_combiner_3d.add_child(wall)

			if wall_bits & WEST:  # W
				var delete_wall_end: bool = (_wall_sides_with_connections(maze, x, y, WEST) <= 1) and (randf() < CHANCE_TO_DELETE_WALL_ENDS)
				if not delete_wall_end:
					wall = _make_single_wall(x != 0)
					wall.rotation_degrees.y = 90
					wall.position += room_position + Vector3(-ROOM_SIZE_HALF, 0, 0)
					csg_combiner_3d.add_child(wall)

			if (y == MAZE_LENGTH - 1) and (wall_bits & SOUTH):  # S
				wall = _make_single_wall(false)
				wall.position += room_position + Vector3(0, 0, ROOM_SIZE_HALF)
				csg_combiner_3d.add_child(wall)

			if (x == MAZE_WIDTH - 1) and (wall_bits & EAST):  # E
				wall = _make_single_wall(false)
				wall.rotation_degrees.y = 90
				wall.position += room_position + Vector3(ROOM_SIZE_HALF, 0, 0)
				csg_combiner_3d.add_child(wall)
			
