extends Node

const SPAWN_POINT = preload("uid://c7wmmnca4o1dx")

@export var enabled:= true


func _ready() -> void:
	generate_spawn_points()


func generate_spawn_points():
	var map: Map = get_tree().get_first_node_in_group("map")
	
	if enabled == false:
		return
	
	if map == null:
		printerr(self, ": Map not found.")
		return
	
	var spawn_layout: TileMapLayer = map.player_spawn
	var cell_size: int = Vars.cell_size
	
	var used_tiles = spawn_layout.get_used_cells()
	
	var tile: Vector2i = used_tiles.pick_random()
	var spawn_inst: Node3D = SPAWN_POINT.instantiate()
	
	add_child(spawn_inst)
	
	spawn_inst.global_position = Vector3(tile.x * cell_size, 0.0, tile.y * cell_size)
