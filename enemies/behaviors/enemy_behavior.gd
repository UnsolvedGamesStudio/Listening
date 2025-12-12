extends Node
class_name EnemyBehavior
## Todo: Connect signals in base class
@export var enabled:= true
@onready var O: Enemy


func _ready() -> void:
	if not get_parent().get_parent().get_parent() is Enemy:
		push_error(self, " of ", get_parent().get_parent().get_parent(), ": get_parent().get_parent() is not enemy")
		return
	
	O = get_parent().get_parent().get_parent()
	
	await O.ready
	enter()


func enter():
	pass


func find_player() -> Player:
	var player: Player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		push_error(self, ": player not found")
	
	return player


func set_stats():
	pass
