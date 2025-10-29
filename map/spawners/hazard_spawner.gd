extends Node

const SPIKES = preload("uid://c86l6d7h0h8wa")

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
	
	var hazards_layout: TileMapLayer = map.hazards
	var cell_size: int = Vars.cell_size
	
	var used_tiles = hazards_layout.get_used_cells()
	
	for tile in used_tiles:
		var hazard_inst: SpikesTile = SPIKES.instantiate()
		
		add_child(hazard_inst)
		hazard_inst.global_position = Vector3(tile.x * cell_size, 0.0, tile.y * cell_size)
