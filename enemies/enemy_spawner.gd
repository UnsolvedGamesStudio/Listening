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
		
		if not check_data(enemy_layout, tile) == null:
			enemy_inst.data = check_data(enemy_layout, tile)
		
		add_child(enemy_inst)
		enemy_inst.global_position = Vector3(tile.x * cell_size, 1.0, tile.y * cell_size)


func check_data(enemy_layout: TileMapLayer, coords: Vector2i):
	var enemy_data: EnemyResource 
	for tile_coords in enemy_layout.get_used_cells():
		var tile_data: TileData = enemy_layout.get_cell_tile_data(tile_coords)
		
		if tile_coords == coords:
			enemy_data = tile_data.get_custom_data("enemy_data")
	
	return enemy_data
