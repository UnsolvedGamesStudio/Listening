extends Node
## Todo: When an enemy can't move, rerun omitting what blocked it
## Todo: subclasses for ground and air movement
# ---- CONFIG ----
var max_vertical_diff: float = 1.5      # maximum allowed height difference between neighbors

# ---- INTERNAL DATA ----
var astar: AStar3D = AStar3D.new()
var cell_to_id: Dictionary = {}         # Vector3 -> int
var id_to_cell: Dictionary = {}         # int -> Vector3
var _debug_spheres: Array = []

# Directions
const ORTHO_DIRS := [
	Vector3(1, 0, 0),
	Vector3(-1, 0, 0),
	Vector3(0, 0, 1),
	Vector3(0, 0, -1),
]

const DIAG_DIRS := [
	Vector3(1, 0, 1),
	Vector3(1, 0, -1),
	Vector3(-1, 0, 1),
	Vector3(-1, 0, -1),
]


func _ready() -> void:
	Bus.level_layout_ready.connect(on_level_layout_ready)


func on_level_layout_ready():
	cell_to_id.clear()
	id_to_cell.clear()
	
	# Generate all cells
	for cell in get_tree().get_nodes_in_group("cell"):
		add_cell(cell.global_position)
	
	# Build connections
	for cell_pos in cell_to_id.keys():
		rebuild_cell_connections(cell_pos, true, [Find.P()])


# ---- PUBLIC API ----

func add_cell(cell_pos: Vector3) -> int:
	if cell_to_id.has(cell_pos):
		return cell_to_id[cell_pos]
	
	var id = cell_to_id.size()
	
	cell_to_id[cell_pos] = id
	id_to_cell[id] = cell_pos
	
	astar.add_point(id, cell_pos)
	
	return id


func remove_cell(cell_pos: Vector3) -> void:
	if not cell_to_id.has(cell_pos):
		return
	
	var id = cell_to_id[cell_pos]
	
	for neighbor_id in astar.get_point_connections(id):
		astar.disconnect_points(id, neighbor_id)
	
	astar.remove_point(id)
	cell_to_id.erase(cell_pos)
	id_to_cell.erase(id)


func move_cell(old_pos: Vector3, new_pos: Vector3) -> void:
	if not cell_to_id.has(old_pos):
		return
	
	var id = cell_to_id[old_pos]
	
	cell_to_id.erase(old_pos)
	cell_to_id[new_pos] = id
	id_to_cell[id] = new_pos
	astar.set_point_position(id, new_pos)
	rebuild_cell_connections(new_pos)  # rebuild neighbors after moving

# Rebuild neighbors of a single cell
func rebuild_cell_connections(cell_pos: Vector3, allow_diagonals: bool = true, ignore_occupants: Array = []) -> void:
	if not cell_to_id.has(cell_pos):
		return
	
	var id = cell_to_id[cell_pos]
	
	# Disconnect all existing neighbors
	for neighbor_id in astar.get_point_connections(id):
		astar.disconnect_points(id, neighbor_id)
	
	# Connect orthogonal neighbors
	for dir in ORTHO_DIRS:
		var npos = cell_pos + dir * Vars.cell_size
		
		if cell_to_id.has(npos) and can_connect(cell_pos, npos, ignore_occupants):
			var nid = cell_to_id[npos]
			
			astar.connect_points(id, nid, true)
	
	# Connect diagonals if allowed
	if allow_diagonals:
		for dir in DIAG_DIRS:
			var npos = cell_pos + dir * Vars.cell_size
			
			if cell_to_id.has(npos) and can_connect_diagonal(cell_pos, npos, ignore_occupants):
				var nid = cell_to_id[npos]
				
				astar.connect_points(id, nid, true)

# Get path between two cells
func get_cell_path(start_pos: Vector3, end_pos: Vector3, draw_path:= false) -> Array:
	if not cell_to_id.has(start_pos) or not cell_to_id.has(end_pos):
		return []
	
	var start_id = cell_to_id[start_pos]
	var end_id = cell_to_id[end_pos]
	var path:= astar.get_point_path(start_id, end_id)
	
	if draw_path == true:
		draw_debug_path(path)
	
	return path

# Get path between two cells after reconnecting the relevant cells if any change was signaled
func get_dynamic_path(start_pos: Vector3, end_pos: Vector3, allow_diagonals: bool = true, ignore_occupants: Array = [], draw_path:= false) -> Array:
	# Rebuild relevant connections first
	rebuild_cell_connections(start_pos, allow_diagonals, ignore_occupants)
	rebuild_cell_connections(end_pos, allow_diagonals, ignore_occupants)
	
	# Rebuild neighbors
	for dir in ORTHO_DIRS + DIAG_DIRS:
		var neighbor_pos_start = start_pos + dir * Vars.cell_size
		
		if cell_to_id.has(neighbor_pos_start):
			rebuild_cell_connections(neighbor_pos_start, allow_diagonals, ignore_occupants)
		
		var neighbor_pos_end = end_pos + dir * Vars.cell_size
		
		if cell_to_id.has(neighbor_pos_end):
			rebuild_cell_connections(neighbor_pos_end, allow_diagonals, ignore_occupants)
	
	return get_cell_path(start_pos, end_pos)


func get_next_cell(start_pos: Vector3, end_pos: Vector3, allow_diagonals: bool = true, ignore_occupants: Array = [], draw_path:= false):
	var next_cell: Cell
	var current_path:= get_dynamic_path(start_pos, end_pos, allow_diagonals, ignore_occupants, draw_path)
	
	if current_path.size() <= 2:
		return null
	
	next_cell = get_cell_node(current_path[1])
	
	return next_cell


# ---- INTERNAL HELPERS ----

func can_connect(a_pos: Vector3, b_pos: Vector3, ignore_occupants: Array) -> bool:
	# Check vertical difference
	if absf(a_pos.y - b_pos.y) > max_vertical_diff:
		return false
	
	var a_cell = get_cell_node(a_pos)
	var b_cell = get_cell_node(b_pos)
	
	if not a_cell or not b_cell:
		return false
	
	if b_cell.is_cell_blocked(ignore_occupants):
		return false
	if b_cell.forgotten == true:
		return false
	
	# Check walls
	var delta = b_pos - a_pos
	
	if abs(delta.x) > 0:
		if delta.x > 0:
			return not (a_cell.walls[Cell.WallSide.EAST] or b_cell.walls[Cell.WallSide.WEST])
		else:
			return not (a_cell.walls[Cell.WallSide.WEST] or b_cell.walls[Cell.WallSide.EAST])
	
	elif abs(delta.z) > 0:
		if delta.z > 0:
			return not (a_cell.walls[Cell.WallSide.SOUTH] or b_cell.walls[Cell.WallSide.NORTH])
		else:
			return not (a_cell.walls[Cell.WallSide.NORTH] or b_cell.walls[Cell.WallSide.SOUTH])
	
	return true


func can_connect_diagonal(a_pos: Vector3, b_pos: Vector3, ignore_occupants: Array) -> bool:
	var delta = (b_pos - a_pos) / Vars.cell_size
	
	# Check both orthogonal neighbors exist and can connect
	var step1 = a_pos + Vector3(delta.x, 0, 0) * Vars.cell_size
	var step2 = a_pos + Vector3(0, 0, delta.z) * Vars.cell_size
	if not (cell_to_id.has(step1) and cell_to_id.has(step2)):
		return false
	
	if not (can_connect(a_pos, step1, ignore_occupants) and can_connect(a_pos, step2, ignore_occupants)):
		return false
	
	# Also check diagonal target itself
	if not can_connect(a_pos, b_pos, ignore_occupants):
		return false
	
	return true


func get_cell_node(pos: Vector3):
	for cell in get_tree().get_nodes_in_group("cell"):
		if cell.global_position == pos:
			return cell
	
	return null

# Call this to visualize a path
func draw_debug_path(path: Array, sphere_radius: float = 0.2, color: Color = Color(0.103, 0.532, 0.625, 1.0)) -> void:
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
