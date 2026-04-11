extends Node
## vector3i would be more performant
const DIRECTIONS:= [
	Vector3(1, 0, 0),
	Vector3(-1, 0, 0),
	Vector3(0, 0, 1),
	Vector3(0, 0, -1),
]

const WALL_MAPPINGS: Dictionary[Vector3, Array] = {
	Vector3(1, 0, 0): [Cell.WallSide.EAST, Cell.WallSide.WEST],   # Moving East
	Vector3(-1, 0, 0): [Cell.WallSide.WEST, Cell.WallSide.EAST],  # Moving West
	Vector3(0, 0, 1): [Cell.WallSide.SOUTH, Cell.WallSide.NORTH], # Moving South
	Vector3(0, 0, -1): [Cell.WallSide.NORTH, Cell.WallSide.SOUTH] # Moving North
}

var astar: AStar3D = AStar3D.new()
var _debug_spheres: Array = []

var id_to_cell: Dictionary[int, Cell] = {}

var pos_to_id: Dictionary[Vector3, int] = {}
var id_to_pos: Dictionary[int, Vector3] = {}


#region Internal Helpers
func get_cells() -> Array[Cell]:
	var cells_array: Array[Cell] = []
	
	for cell in get_tree().get_nodes_in_group("cell"):
		if cell is not Cell:
			continue
		
		cells_array.append(cell)
	
	return cells_array


func add_cell(cell: Cell):
	var cell_pos = cell.global_position
	var point_id = pos_to_id.size()
	
	pos_to_id[cell_pos] = point_id
	id_to_pos[point_id] = cell_pos
	id_to_cell[point_id] = cell
	
	astar.add_point(point_id, cell_pos)
	
	connect_to_neighbors(cell_pos)


func connect_to_neighbors(cell_pos: Vector3):
	if not pos_to_id.has(cell_pos):
		return
	
	var point_id = pos_to_id[cell_pos]
	
	for direction in DIRECTIONS:
		var neighbor_pos: Vector3 = cell_pos + direction * Vars.cell_size
		
		if not pos_to_id.has(neighbor_pos):
			continue
		
		var neighbor_id: int = pos_to_id[neighbor_pos]
	
		if not can_connect(point_id, neighbor_id):
			continue
		
		astar.connect_points(point_id, neighbor_id, true)


func can_connect(from_point: int, to_point: int) -> bool:
	if not id_to_cell.has(from_point) or not id_to_cell.has(from_point):
		return false
	
	var from_cell: Cell = id_to_cell[from_point]
	var to_cell: Cell = id_to_cell[to_point]
	
	if walls_blocking(from_cell, to_cell) == false:
		return false
	
	if to_cell.forgotten:
		return false
	
	return true


func walls_blocking(from_cell: Cell, to_cell: Cell) -> bool:
	var from_pos: Vector3 = from_cell.global_position
	var to_pos: Vector3 = to_cell.global_position
	
	var direction = ((to_pos - from_pos) / Vars.cell_size).round()
	
	if not WALL_MAPPINGS.has(direction):
		return true
	
	var leave_wall: int = WALL_MAPPINGS[direction][0]
	var enter_wall: int = WALL_MAPPINGS[direction][1]
	
	var leave_blocked: bool = from_cell.walls[leave_wall]
	var enter_blocked: bool = to_cell.walls[enter_wall]
	
	return not leave_blocked and not enter_blocked


func get_cell_node(cell_pos: Vector3):
	for cell in get_tree().get_nodes_in_group("cell"):
		if cell.global_position == cell_pos:
			return cell
	
	return null

#endregion

## API
func get_next_cell(start_pos: Vector3, end_pos: Vector3, draw_path_debug:= false) -> Cell:
	var next_cell: Cell
	var start_id: int = pos_to_id[start_pos]
	var end_id: int = pos_to_id[end_pos]
	var path: Array = astar.get_point_path(start_id, end_id)
	
	if path.size() < 2:
		return
	
	next_cell = get_cell_node(path[1])
	
	if not next_cell:
		return null
	
	if draw_path_debug:
		draw_debug_path(path)
	
	return next_cell


func update_point_connections(cell_pos: Vector3):
	connect_to_neighbors(cell_pos)


func set_point_weight(cell_pos: Vector3, new_weight):
	if not pos_to_id.has(cell_pos):
		return
	
	var point_id: int = pos_to_id[cell_pos]
	
	
	astar.set_point_weight_scale(point_id, new_weight)


func draw_debug_path(path: Array, sphere_radius: float = 0.15, color: Color = Color(0.189, 0.74, 0.864, 1.0)) -> void:
	# Remove previous spheres
	for sphere in _debug_spheres:
		if is_instance_valid(sphere):
			sphere.queue_free()
	
	_debug_spheres.clear()
	
	# Draw new spheres
	for point in path:
		var sphere = MeshInstance3D.new()
		
		sphere.mesh = SphereMesh.new()
		sphere.mesh.radius = sphere_radius
		sphere.material_override = StandardMaterial3D.new()
		sphere.material_override.albedo_color = color
		
		get_tree().current_scene.add_child(sphere)  # add to current scene
		
		sphere.global_position = point
		
		_debug_spheres.append(sphere)
