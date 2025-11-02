extends Node3D
## Todo: make tiles have their own tilemap
const CELL = preload("uid://b0qtdogq2osyf")


func _ready() -> void:
	generate_layout()


func start_level():
	Filters.fade.play("fade_in")
	await Filters.fade.animation_finished
	Bgm.bus = "BGM"
	
	if Bgm.playing == false:
		Bgm.start_song()


func generate_layout():
	var editor_tiles: TileMapLayer = get_tree().get_first_node_in_group("editor_tiles")
	var cell_size: int = Vars.cell_size
	
	if editor_tiles == null:
		printerr(self, ": Map not found.")
		return
	
	var used_tiles = editor_tiles.get_used_cells()
	
	for tile in used_tiles:
		var cell_inst: WalledCell = CELL.instantiate()
		
		add_child(cell_inst)
		cell_inst.global_position = Vector3(tile.x * cell_size, 0.0, tile.y * cell_size)
		cell_inst.cell_grid_position = Vector2i(cell_inst.global_position.x / Vars.cell_size as int, cell_inst.global_position.z / 2 as int)
		cell_inst.cell.cell_grid_position = Vector2i(cell_inst.global_position.x / Vars.cell_size as int, cell_inst.global_position.z / 2 as int)
		Vars.cell_nodes.append(cell_inst.cell)
		cell_inst.update_faces(used_tiles, cell_size)
