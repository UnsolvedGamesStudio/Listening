extends Node

#var astar:= AStar3D.new()
#
#var max_cell_connect_radius_mult:= 1.5
#var max_cell_connect_height:= 1.0
#
#var cell_coords : Array[Vector3] = []
#var cell_nodes : Dictionary = {}
#var cell_to_id : Dictionary[Vector3, int] = {}
#var id_to_cell : Dictionary[int, Vector3] = {}
#
#var next_id : int = 0
#
#var directions : Array = [
	#Vector3.FORWARD,
	#Vector3.BACK,
	#Vector3.LEFT,
	#Vector3.RIGHT
#]
#
#
#func _ready() -> void:
	#astar = AStar3D.new()
#
#
#func rebuild() -> void:
	## Clear old data
	#astar.clear()
	#cell_to_id.clear()
	#id_to_cell.clear()
	#next_id = 0
	#
	#init_cells()
	#
	## Add points
	#for cell in cell_coords:
		#add_cell(cell)
	#
	#connect_neighbors()
#
#
### This is where we add the existing cells
#func init_cells():
	#for cell in get_tree().get_nodes_in_group("cell"):
		#
		#var grid_position: Vector3 = cell.global_position
		#
		#cell_nodes[grid_position] = cell
		#add_cell(grid_position)
#
#
#func add_cell(cell_position: Vector3) -> void:
	#if cell_to_id.has(cell_position):
		#return
	#
	#var id = next_id
	#next_id += 1
	#
	#cell_to_id[cell_position] = id
	#id_to_cell[id] = cell_position
	#astar.add_point(id, Vector3(cell_position))
#
#
#func remove_cell(cell: Vector3) -> void:
	#if not cell_to_id.has(cell):
		#return
	#
	#var id = cell_to_id[cell]
	#
	## Disconnect from neighbors
	#for neighbor_dir in directions:
		#var neighbor = cell + neighbor_dir
		#if not cell_to_id.has(neighbor):
			#continue
	#
		#var neighbor_id = cell_to_id[neighbor]
		#if astar.are_points_connected(id, neighbor_id):
			#astar.disconnect_points(id, neighbor_id)
	#
	#astar.remove_point(id)
	#
	#cell_to_id.erase(cell)
	#id_to_cell.erase(id)
#
#
#func connect_neighbors():
	#var max_horizontal:= Vars.cell_size * max_cell_connect_radius_mult     # cells touching on X/Z
	#var max_vertical:= max_cell_connect_height   # allowed Y difference
	#
	#for cell_pos in cell_to_id.keys():
		#var id = cell_to_id[cell_pos]
		#
		#for other_pos in cell_to_id.keys():
			#connect_cells(other_pos, cell_pos, id, max_horizontal, max_vertical)
#
#
#func connect_cells(other_pos, cell_pos: Vector3, id, max_horizontal, max_vertical):
	#if other_pos == cell_pos:
		#return
	#
	## if the cells' Y values are too far apart, skip entirely:
	#var vertical_diff : float = abs(cell_pos.y - other_pos.y)
	#if vertical_diff > max_vertical:
		#return
	#
	## Check horizontal distance (XZ only)
	#var horizontal_diff := Vector2(
		#cell_pos.x - other_pos.x,
		#cell_pos.z - other_pos.z
	#).length()
	#
	#if horizontal_diff > max_horizontal:
		#return
	#
	## If both checks pass, connect them
	#var other_id = cell_to_id[other_pos]
	#
	#if astar.are_points_connected(id, other_id):
		#return
	#
	#astar.connect_points(id, other_id, true)
#
#
#func get_cell_path(from_cell: Vector3, to_cell: Vector3, draw_path:= false) -> Array:
	#if not cell_to_id.has(from_cell) or not cell_to_id.has(to_cell):
		#return []
	#
	#var from_id = cell_to_id[from_cell]
	#var to_id = cell_to_id[to_cell]
	#var id_path = astar.get_id_path(from_id, to_id)
	#
	#var cell_path := []
	#
	#for id in id_path:
		#cell_path.append(id_to_cell[id])
	#
	#if draw_path == true:
		#draw_debug_path(cell_path, Find.layout())
	#
	#return cell_path
#
#
#func get_next_cell(from_cell: Vector3, to_cell: Vector3, draw_path:= false):
	#var path:= get_cell_path(from_cell, to_cell, draw_path)
	#
	#if path.size() <= 2:
		#return
	#
	#var cell: Cell = cell_nodes[path[1]]
	#
	#return cell
#
#
#func draw_debug_path(path: Array, parent: Node3D, radius: float = 0.1) -> void:
	#for cell_pos in path:
		#var sphere := MeshInstance3D.new()
		#sphere.mesh = SphereMesh.new()
		#sphere.mesh.radius = radius
	#
		#parent.add_child(sphere)
		#sphere.global_position = cell_pos
