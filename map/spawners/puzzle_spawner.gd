extends Node

const LOCKED_WALL = preload("uid://c5gdwlmng0rsy")


@export var enabled:= true


func _ready() -> void:
	generate_puzzles()


func generate_puzzles():
	var map: Map = get_tree().get_first_node_in_group("map")
	if enabled == false:
		return
	
	if map == null:
		printerr(self, ": Map not found.")
		return
	
	var puzzle_layout: TileMapLayer = map.puzzles
	var cell_size: int = Vars.cell_size
	
	var used_tiles = puzzle_layout.get_used_cells()
	
	for tile in used_tiles:
		if puzzle_layout.get_cell_tile_data(tile) == null:
			return
		
		var custom_data: PackedScene = puzzle_layout.get_cell_tile_data(tile).get_custom_data("puzzle_scene")
		
		if custom_data == null:
			return
		
		var puzzle_inst: Node = custom_data.instantiate()
		
		add_child(puzzle_inst)
		puzzle_inst.global_position = Vector3(tile.x * cell_size, 0.0, tile.y * cell_size)
