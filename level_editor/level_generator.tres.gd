extends Node

@export var enabled:= true

## Todo: "orienter" tiles that serve to rotate directional objects when they spawn
## Todo: wall tilemap
## Todo: turn enemy resource tile data into separate enemy scenes
## Todo: consolidate spawners into a single script/class
## Todo: make it delete tilemaps after spawning
## Todo: have the level editor be a tool script that generates the layout as an editable packed scene


func _ready() -> void:
	generate()


func generate():
	var editor: Node = get_tree().get_first_node_in_group("level_editor")
	
	if enabled == false:
		return
	
	if editor == null:
		printerr(self, ": level_editor not found.")
		return
	
	generate_each_layer(editor)


func generate_each_layer(editor: Node):
	for layer: TileMapLayer in editor.get_children():
		var used_tiles = layer.get_used_cells()
		generate_layer_tile(used_tiles, layer)


func generate_layer_tile(used_tiles: Array[Vector2i], layer: TileMapLayer):
	for tile in used_tiles:
		var scene_data: PackedScene = layer.get_cell_tile_data(tile).get_custom_data("scene")
		
		if scene_data == null:
			return
		
		var scene_inst: Node = scene_data.instantiate()
		
		add_child(scene_inst)
		scene_inst.global_position = Vector3(tile.x * Vars.cell_size, 0.0, tile.y * Vars.cell_size)
