extends Node

@export var enabled:= true


func _ready() -> void:
	generate_pickups()


func generate_pickups():
	var map: Map = get_tree().get_first_node_in_group("map")
	if enabled == false:
		return
	
	if map == null:
		printerr(self, ": Map not found.")
		return
	
	var pickup_layout: TileMapLayer = map.pickups
	var cell_size: int = Vars.cell_size
	
	var used_tiles = pickup_layout.get_used_cells()
	
	for tile in used_tiles:
		var custom_data: PackedScene = pickup_layout.get_cell_tile_data(tile).get_custom_data("pickup_scene")
		
		if custom_data == null:
			return
		
		var pickup_inst: Node = custom_data.instantiate()
		
		add_child(pickup_inst)
		pickup_inst.global_position = Vector3(tile.x * cell_size, 0.0, tile.y * cell_size)
