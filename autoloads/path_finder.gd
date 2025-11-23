extends Node

var astar:= AStar2D.new()

var cells : Array[Vector2i] = []
var cell_nodes : Dictionary = {}
var cell_to_id : Dictionary = {}  ## Vector2i -> int
var id_to_cell : Dictionary = {}  ## int -> Vector2i
var next_id : int = 0

var directions : Array = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]


func _ready() -> void:
	astar = AStar2D.new()


func rebuild(cells_list: Array) -> void:
	# Clear old data
	cells = cells_list.duplicate()
	astar.clear()
	cell_to_id.clear()
	id_to_cell.clear()
	next_id = 0
	
	init_cells()
	
	# Add points
	for cell in cells:
		add_cell(cell)
	
	# Connect neighbors
	connect_neighbors()


func init_cells():
	for cell in get_tree().get_nodes_in_group("cell"):
		if not "cell_grid_position" in cell:
			continue
	
		cell.handle_gridless()
		
		var grid_position: Vector2i = cell.cell_grid_position
		cell_nodes[grid_position] = cell
		add_cell(grid_position)


func add_cell(cell: Vector2i) -> void:
	if cell_to_id.has(cell):
		return
	
	var id = next_id
	next_id += 1
	
	cell_to_id[cell] = id
	id_to_cell[id] = cell
	astar.add_point(id, Vector2(cell))


func remove_cell(cell: Vector2i) -> void:
	if not cell_to_id.has(cell):
		return
	
	var id = cell_to_id[cell]
	
	# Disconnect from neighbors
	for neighbor_dir in directions:
		var neighbor = cell + neighbor_dir
		if not cell_to_id.has(neighbor):
			continue
	
		var neighbor_id = cell_to_id[neighbor]
		if astar.are_points_connected(id, neighbor_id):
			astar.disconnect_points(id, neighbor_id)
	
	astar.remove_point(id)
	
	cell_to_id.erase(cell)
	id_to_cell.erase(id)


func connect_neighbors() -> void:
	for cell in cell_to_id.keys():
		var id = cell_to_id[cell]
	
		# Generate neighbor positions and filter only existing ones
		var neighbor_ids := []
		for dir in directions:
			var neighbor = cell + dir
			if cell_to_id.has(neighbor):
				neighbor_ids.append(cell_to_id[neighbor])
		
		# Connect to all neighbors
		for neighbor_id in neighbor_ids:
			if not astar.are_points_connected(id, neighbor_id):
				astar.connect_points(id, neighbor_id, true)


func get_cell_path(from_cell: Vector2i, to_cell: Vector2i, draw_path:= false) -> Array:
	if not cell_to_id.has(from_cell) or not cell_to_id.has(to_cell):
		return []
	
	var from_id = cell_to_id[from_cell]
	var to_id = cell_to_id[to_cell]
	
	var id_path = astar.get_id_path(from_id, to_id)
	var cell_path := []
	
	for id in id_path:
		cell_path.append(id_to_cell[id])
	
	if draw_path == true:
		draw_debug_path(cell_path, Find.layout())
	
	return cell_path


func draw_debug_path(path: Array, parent: Node3D, radius: float = 0.1) -> void:
	for cell in path:
		var sphere := MeshInstance3D.new()
		sphere.mesh = SphereMesh.new()
		sphere.mesh.radius = radius
	
		parent.add_child(sphere)
		sphere.global_position = Vector3(cell.x * Vars.cell_size, 0, cell.y * Vars.cell_size)
