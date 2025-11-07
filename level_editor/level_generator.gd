extends Node
## Todo: read and translate the rotation of the tile (tiledata) into the spawn rotation
## Todo: wall tilemap
## Todo: have the level editor be a tool script that generates the layout as an editable packed scene
## Todo: investigate cyclic references
## Todo: make enemy id's customizable like the boxes etc
## Todo: make a modifier tile that reveals another tile when affected enemies are defeated
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
	
	blueprint.queue_free()


func generate_each_layer(blueprint: Node):
	for layer: TileMapLayer in blueprint.get_children():
		var used_tiles = layer.get_used_cells()
		
		if layer.is_in_group("editor_cells"):
			generate_cells(used_tiles, layer)
		
		if layer.is_in_group("editor_objects"):
			generate_object_tiles(used_tiles, layer)


func generate_cells(used_tiles: Array[Vector2i], layer: TileMapLayer):
	var cell_size: float = Vars.cell_size
	
	for tile in used_tiles:
		var scene_data: PackedScene = layer.get_cell_tile_data(tile).get_custom_data("scene")
		if scene_data == null:
			return
		
		var cell_inst: Node = scene_data.instantiate()
		
		add_child(cell_inst)
		
		cell_inst.global_position = Vector3(tile.x * cell_size, layer.elevation, tile.y * cell_size)
		cell_inst.cell.cell_grid_position = Vector2i(cell_inst.cell.global_position.x / Vars.cell_size as int, cell_inst.cell.global_position.z / 2 as int)
		
		Vars.cell_nodes.append(cell_inst.cell)
		Vars.cell_coordinates.append(tile)
		
		if cell_inst.has_method("update_faces"):
			cell_inst.update_faces(used_tiles, cell_size)


func generate_object_tiles(used_tiles: Array[Vector2i], layer: TileMapLayer):
	for tile in used_tiles:
		var scene_data: PackedScene = layer.get_cell_tile_data(tile).get_custom_data("scene")
		var unique_object_id: int = layer.get_cell_tile_data(tile).get_custom_data("unique_object_id")
		
		if scene_data == null:
			printerr(tile, ": no scene data found")
			return
		
		var scene_inst: Node = scene_data.instantiate()
		
		if "puzzle_id" in scene_inst:
			var puzzle_id: int = layer.get_cell_tile_data(tile).get_custom_data("puzzle_id")
			set_puzzle_id(scene_inst, puzzle_id)
		
		if scene_inst is MusicBox:
			var box_id: int = layer.get_cell_tile_data(tile).get_custom_data("box_id")
			set_box_id(scene_inst, box_id)
		
		add_child(scene_inst)
		scene_inst.global_position = Vector3(tile.x * Vars.cell_size, 0.0, tile.y * Vars.cell_size)
		
		if scene_inst is UniqueObjectPlacer:
			spawn_unique_object(scene_inst, unique_object_id)


func set_puzzle_id(scene_inst: Node, puzzle_id: int):
	scene_inst.puzzle_id = puzzle_id
	
	if scene_inst is RemembererPickup:
		var blueprint: LevelEditorBlueprint = get_tree().get_first_node_in_group("level_blueprint")
		
		if puzzle_id > blueprint.remembering_costs.size():
			return
		
		var cost:= blueprint.remembering_costs[puzzle_id - 1]
		scene_inst.required_synapses = cost


func set_box_id(box: MusicBox, box_id: int):
	var blueprint: Node = get_tree().get_first_node_in_group("level_blueprint")
	box.box_id = box_id
	
	if not "chest_loot_scenes" in blueprint:
		return
	
	if blueprint.chest_loot_scenes == {}:
		return
	
	if box_id > blueprint.chest_loot_scenes.size():
		return
	
	for object in blueprint.chest_loot_scenes[box_id - 1]:
		print(object)
		if object is not PackedScene:
			return
		
		box.contents.append(object)


func spawn_unique_object(placer: UniqueObjectPlacer, unique_object_id: int):
	var blueprint: Node = get_tree().get_first_node_in_group("level_blueprint")
	
	if not "unique_objects" in blueprint:
		return
	
	if blueprint.unique_objects == []:
		return
	
	if unique_object_id > blueprint.unique_objects.size():
		return
	
	var object_scene: Node = blueprint.unique_objects[unique_object_id - 1].instantiate()
	add_child(object_scene)
	object_scene.global_position = placer.global_position
