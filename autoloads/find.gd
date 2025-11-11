extends Node


func P() -> Player:
	var player:= get_tree().get_first_node_in_group("player")
	
	if player == null:
		printerr("Player not found")
	
	return player
