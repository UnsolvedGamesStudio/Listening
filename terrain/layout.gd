extends Node3D

const CELL = preload("uid://b0qtdogq2osyf")

var map: Map


func _ready() -> void:
	map = get_tree().get_first_node_in_group("map")
	var cell_size: int = Vars.cell_size
	var map_layout:= map.floor_layout
	
	if map == null:
		printerr(self, ": Map not found.")
		return
	
	var used_tiles = map_layout.get_used_cells()
	
	for tile in used_tiles:
		var cell_inst: Cell = CELL.instantiate()
		
		add_child(cell_inst)
		Vars.cell_nodes.append(cell_inst)
		cell_inst.global_position = Vector3(tile.x * cell_size, 0.0, tile.y * cell_size)
	
	for cell in Vars.cell_nodes:
		cell.update_faces(used_tiles, cell_size)
