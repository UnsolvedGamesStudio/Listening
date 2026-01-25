extends Node
## Todo: Read and translate the rotation of the tile (tiledata) into the spawn rotation
## Todo: Wall tilemap
## Todo: Have the level editor be a tool script that generates the layout as an editable packed scene
## Todo: Make enemy id's customizable like the boxes etc
## Todo: Make a modifier tile that reveals another tile when affected enemies are defeated
## Todo: Make more things work from the "level ready" signal, rather than being called from other classes
## Todo: Unify "object already saved" logic
var main: MainScene
var enabled:= true
var current_blueprint: PackedScene


func _ready() -> void:
	main = get_tree().get_first_node_in_group("main_scene")
	
	if main == null:
		push_error("MainScene node not found")
		return
	
	if main.use_test_blueprint:
		current_blueprint = main.test_blueprint
	else:
		current_blueprint = main.default_blueprint


func activate():
	if not SceneManager.is_current_scene(SceneManager.Scenes.LAYOUT):
		return
	
	var blueprint_inst: Node = current_blueprint.instantiate()
	add_child(blueprint_inst)
	
	generate(blueprint_inst)


func generate(blueprint):
	if enabled == false:
		return
	
	if blueprint == null:
		print(self, ": No level_blueprint.")
		return
	
	for child in blueprint.get_children():
		if not child is BlueprintFloor:
			continue
		
		update_floor_levels(child)
		generate_floor_layers(child)
	
	blueprint.queue_free()
	Bus.level_done_generating.emit()
	Bus.level_layout_ready.emit()


func update_floor_levels(blueprint_floor: BlueprintFloor):
	var floor_number:= blueprint_floor.floor_number
	var floor_height:= blueprint_floor.height
	
	Vars.floor_heights[floor_number] = floor_height


func generate_floor_layers(blueprint_floor: BlueprintFloor):
	for layer in blueprint_floor.get_children():
		var used_tiles = layer.get_used_cells()
		
		if layer.is_in_group("editor_cells"):
			generate_cells(used_tiles, layer, blueprint_floor)
		
		if layer.is_in_group("editor_objects"):
			generate_object_tiles(used_tiles, layer, blueprint_floor)

## Todo: Maybe combine both generation functions
func generate_cells(used_tiles: Array[Vector2i], layer: TileMapLayer, blueprint_floor: BlueprintFloor):
	var layout:= get_tree().get_first_node_in_group("layout")
	var cell_size: float = Vars.cell_size
	
	for tile in used_tiles:
		var scene_data: PackedScene = layer.get_cell_tile_data(tile).get_custom_data("scene")
		if scene_data == null:
			continue
		
		var cell_inst: Node = scene_data.instantiate()
		layout.add_child(cell_inst)
		
		if "starting_floor" in cell_inst.cell:
			cell_inst.cell.starting_floor = blueprint_floor.floor_number
		
		var world_pos:= tile_to_world(tile, blueprint_floor.height)
		
		cell_inst.global_position = world_pos
		
		Vars.cell_nodes.append(cell_inst.cell)


func generate_object_tiles(used_tiles: Array[Vector2i], layer: TileMapLayer, blueprint_floor: BlueprintFloor):
	var layout:= get_tree().get_first_node_in_group("layout")
	for tile in used_tiles:
		var cell_data:= layer.get_cell_tile_data(tile)
		var scene_data: PackedScene = cell_data.get_custom_data("scene")
		var unique_object_id: int = cell_data.get_custom_data("unique_object_id")
		
		if scene_data == null:
			push_error(tile, ": no scene data found")
			continue
		
		var scene_inst: Node = scene_data.instantiate()
		var inst_save_id:= "%d_%d" % [tile.x, tile.y]
		
		if SaveManager.check_node_collected(scene_inst, inst_save_id) == true:
			if scene_inst is SynapsePickup:
				Vars.total_synapses += 1
			
			if scene_inst is NeuronPickup:
				Vars.total_neurons += 1
			
			scene_inst.queue_free()
			continue
		
		set_save_id(scene_inst, inst_save_id)
		
		if "puzzle_id" in scene_inst:
			var puzzle_id: int = layer.get_cell_tile_data(tile).get_custom_data("puzzle_id")
			puzzle_setup(scene_inst, puzzle_id)
		
		if scene_inst is MusicBox:
			var box_id: int = layer.get_cell_tile_data(tile).get_custom_data("box_id")
			box_setup(scene_inst, box_id)
		
		layout.add_child(scene_inst)
		
		scene_inst.global_position = tile_to_world(tile, blueprint_floor.height)
		
		rotate_scene(scene_inst, tile, layer)
		
		if scene_inst is UniqueObjectPlacer:
			unique_object_setup(scene_inst, unique_object_id)


func set_save_id(inst: Node, inst_save_id: String):
	if not "save_id" in inst:
		return
	
	inst.save_id = inst_save_id


func rotate_scene(scene: Node3D, tile: Vector2i, layer: TileMapLayer):
	var alternate:= layer.get_cell_alternative_tile(tile)
	var flip_h:= alternate & TileSetAtlasSource.TRANSFORM_FLIP_H == TileSetAtlasSource.TRANSFORM_FLIP_H
	var flip_v:= alternate & TileSetAtlasSource.TRANSFORM_FLIP_V == TileSetAtlasSource.TRANSFORM_FLIP_V
	
	
	if flip_h == false and flip_v == false:
		return
	
	if flip_h == true and flip_v == false:
		scene.global_rotation_degrees.y = -90.0
	
	if flip_h == true and flip_v == true:
		scene.global_rotation_degrees.y = 180.0
	
	if flip_h == false and flip_v == true:
		scene.global_rotation_degrees.y = 90.0


func puzzle_setup(scene_inst: Node, puzzle_id: int):
	scene_inst.puzzle_id = puzzle_id
	
	if scene_inst is RemembererPickup:
		var blueprint: LevelEditorBlueprint = get_tree().get_first_node_in_group("level_blueprint")
		
		if puzzle_id > blueprint.remembering_costs.size():
			return
		
		var cost:= blueprint.remembering_costs[puzzle_id - 1]
		scene_inst.required_synapses = cost


func unique_object_setup(placer: UniqueObjectPlacer, unique_object_id: int):
	var layout:= get_tree().get_first_node_in_group("layout")
	var blueprint: Node = get_tree().get_first_node_in_group("level_blueprint")
	
	if not "unique_objects" in blueprint:
		return
	
	if blueprint.unique_objects == []:
		return
	
	if unique_object_id > blueprint.unique_objects.size():
		return
	
	var object_scene: Node = blueprint.unique_objects[unique_object_id - 1].instantiate()
	layout.add_child(object_scene)
	object_scene.global_position = placer.global_position


func box_setup(box: MusicBox, box_id: int):
	var blueprint: Node = get_tree().get_first_node_in_group("level_blueprint")
	box.box_id = box_id
	blueprint.init_box_arrays()
	
	if not "box_arrays" in blueprint:
		return
	
	if blueprint.box_arrays == []:
		return
	
	if box_id > blueprint.box_arrays.size():
		return
	
	for object in blueprint.box_arrays[box_id - 1]:
		if object is not PackedScene:
			continue
		
		box.contents.append(object)


func tile_to_world(tile: Vector2i, height: float) -> Vector3:
	return Vector3(tile.x * Vars.cell_size, height, tile.y * Vars.cell_size)
