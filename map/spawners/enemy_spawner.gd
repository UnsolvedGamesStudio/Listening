extends Node

const ENEMY = preload("uid://dt0weymuwtkif")

@export var enabled:= true


func _ready() -> void:
	generate_enemies()


func generate_enemies():
	var map: Map = get_tree().get_first_node_in_group("map")
	if enabled == false:
		return
	
	if map == null:
		printerr(self, ": Map not found.")
		return
	
	var enemy_layout: TileMapLayer = map.enemies
	var cell_size: int = Vars.cell_size
	
	var used_tiles = enemy_layout.get_used_cells()
	
	for tile in used_tiles:
		var enemy_inst: Enemy = ENEMY.instantiate()
		var custom_data: EnemyResource = enemy_layout.get_cell_tile_data(tile).get_custom_data("enemy_data")
		
		if custom_data == null:
			printerr(self, ": custom data of tile", tile, " not found, defaulting to placeholder")
		
		if not custom_data == null:
			enemy_inst.data = custom_data
		
		add_child(enemy_inst)
		enemy_inst.global_position = Vector3(tile.x * cell_size, 1.0, tile.y * cell_size)
