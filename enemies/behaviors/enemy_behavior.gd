extends Node
class_name EnemyBehavior

@onready var O: Enemy


func find_player() -> Player:
	var player: Player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		printerr(self, ": player not found")
	
	return player


func set_stats():
	pass
