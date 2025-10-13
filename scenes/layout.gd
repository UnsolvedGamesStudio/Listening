extends Node3D

const CELL = preload("uid://b0qtdogq2osyf")

var cell_size:= 2
var map: TileMapLayer


func _ready() -> void:
	map = get_tree().get_first_node_in_group("map")
	
	var cells_nodes: Array[Cell] = []
	var used_tiles = map.get_used_cells()
	
	for tile in used_tiles:
		var cell_inst: Cell = CELL.instantiate()
		
		add_child(cell_inst)
		cells_nodes.append(cell_inst)
		cell_inst.global_position = Vector3(tile.x * cell_size, 0.0, tile.y * cell_size)
	
	for cell in cells_nodes:
		cell.update_faces(used_tiles, cell_size)
