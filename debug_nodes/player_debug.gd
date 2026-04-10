extends Node

@export var enabled:= false
@export var enable_all_infinites:= false

@export_group("Infinite Cheats")
@export var infinite_hp:= false
@export var infinite_dopamine:= false
@export var infinite_synapses:= false
@export var infinite_keys:= false

var player: Player


func _ready() -> void:
	if not OS.has_feature("editor"):
		enabled = false


func _process(delta: float) -> void:
	if not enabled:
		return
	
	player = get_tree().get_first_node_in_group("player")
	
	apply_infinites()


func apply_infinites():
	if (enable_all_infinites or infinite_hp) and player:
		player.hp = player.max_hp
	
	if enable_all_infinites or infinite_dopamine:
		Vars.dopamine = Vars.max_dopamine
	
	if enable_all_infinites or infinite_synapses:
		Vars.synapses = 999
	
	if enable_all_infinites or infinite_keys:
		Vars.inventory[Vars.item_types.F_KEY] = {"amount" : 999}
