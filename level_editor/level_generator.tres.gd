extends Node
## Todo: read and translate the rotation of the tile (tiledata) into the spawn rotation
## Todo: wall tilemap
## Todo: make it delete tilemaps after spawning
## Todo: have the level editor be a tool script that generates the layout as an editable packed scene

const WALLED_CELL = preload("uid://b0qtdogq2osyf")

@export var enabled:= true



func _ready() -> void:
	generate()


func generate():
	var blueprint: Node = get_tree().get_first_node_in_group("level_blueprint")
	
	if enabled == false:
		return
	
	if blueprint == null:
		printerr(self, ": level_blueprint not found.")
		return
	
	generate_each_layer(blueprint)


func generate_each_layer(blueprint: Node):
	for layer: TileMapLayer in blueprint.get_children():
		var used_tiles = layer.get_used_cells()
		
		if layer.is_in_group("editor_cells"):
			generate_cells(used_tiles, layer)
		
		if layer.is_in_group("editor_objects"):
			generate_object_tiles(used_tiles, layer)


func generate_cells(used_tiles: Array[Vector2i], layer: TileMapLayer):
	var editor_tiles: TileMapLayer = get_tree().get_first_node_in_group("editor_cells")
	var cell_size: float = Vars.cell_size
	
	if editor_tiles == null:
		printerr(self, ": blueprint not found.")
		return
	
	for tile in used_tiles:
		var cell_inst: WalledCell = WALLED_CELL.instantiate()
		
		add_child(cell_inst)
		cell_inst.global_position = Vector3(tile.x * cell_size, 0.0, tile.y * cell_size)
		cell_inst.cell_grid_position = Vector2i(cell_inst.global_position.x / Vars.cell_size as int, cell_inst.global_position.z / 2 as int)
		cell_inst.cell.cell_grid_position = Vector2i(cell_inst.global_position.x / Vars.cell_size as int, cell_inst.global_position.z / 2 as int)
		Vars.cell_nodes.append(cell_inst.cell)
		Vars.cell_coordinates.append(tile)
		cell_inst.update_faces(used_tiles, cell_size)


func generate_object_tiles(used_tiles: Array[Vector2i], layer: TileMapLayer):
	for tile in used_tiles:
		var scene_data: PackedScene = layer.get_cell_tile_data(tile).get_custom_data("scene")
		var puzzle_id: int = layer.get_cell_tile_data(tile).get_custom_data("puzzle_id")
		
		if scene_data == null:
			return
		
		var scene_inst: Node = scene_data.instantiate()
		set_puzzle_id(scene_inst, puzzle_id)
		add_child(scene_inst)
		scene_inst.global_position = Vector3(tile.x * Vars.cell_size, 0.0, tile.y * Vars.cell_size)


func set_puzzle_id(scene_inst: Node, puzzle_id: int):
	if not "puzzle_id" in scene_inst:
		return
	
	scene_inst.puzzle_id = puzzle_id
	
	if scene_inst is RemembererPickup:
		var blueprint: LevelEditorBlueprint = get_tree().get_first_node_in_group("level_blueprint")
		
		if puzzle_id - 1 > blueprint.remembering_costs.size():
			return
		
		var cost:= blueprint.remembering_costs[puzzle_id - 1]
		scene_inst.required_synapses = cost
