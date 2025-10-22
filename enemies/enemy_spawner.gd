extends Node

const ENEMY = preload("uid://dt0weymuwtkif")

@export var enabled:= true

var map: Map


func _ready() -> void:
	map = get_tree().get_first_node_in_group("map")
	generate_enemies()


func generate_enemies():
	if enabled == false:
		return
	
	if map == null:
		printerr(self, ": Map not found.")
		return
	
	var enemy_layout: TileMapLayer = map.enemies
	var cell_size: int = Vars.cell_size
	
	var enemy_nodes: Array[Enemy] = []
	var used_tiles = enemy_layout.get_used_cells()
	
	for tile in used_tiles:
		var enemy_inst: Enemy = ENEMY.instantiate()
		
		add_child(enemy_inst)
		enemy_nodes.append(enemy_inst)
		enemy_inst.global_position = Vector3(tile.x * cell_size, 1.0, tile.y * cell_size)
