extends Node
class_name CritterBehavior

var O: Critter


func _ready() -> void:
	if not owner is Critter:
		printerr(self, " : Owner is not Critter, freeing self")
		queue_free()
	
	O = owner
	
	enter()
	
	await Bus.level_layout_ready
	
	level_ready()


func enter():
	pass


func _physics_process(delta: float) -> void:
	p_process(delta)


func p_process(delta: float):
	pass


func level_ready():
	pass
