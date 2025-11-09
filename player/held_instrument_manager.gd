extends Node

const CARILLON_HELD = preload("res://instruments/carillon_held.tscn")
const LUTE_HELD = preload("res://instruments/lute_held.tscn")


func _ready() -> void:
	update_instrument()


func update_instrument():
	if not get_children() == []:
		get_child(0).queue_free()
	
	if Vars.current_instrument == Vars.instrument_types.LUTE:
		add_scene(LUTE_HELD)
	
	if Vars.current_instrument == Vars.instrument_types.CARILLON:
		add_scene(CARILLON_HELD)


func add_scene(scene: PackedScene):
	var instrument_inst:= scene.instantiate()
	instrument_inst.player = get_parent()
	add_child(instrument_inst)
