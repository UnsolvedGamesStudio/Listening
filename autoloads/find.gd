extends Node


func P() -> Player:
	var player_scene:= get_tree().get_first_node_in_group("player")
	
	if player_scene == null:
		printerr("Player not found")
	
	return player_scene


func layout() -> Player:
	var layout_scene:= get_tree().get_first_node_in_group("layout")
	
	if layout_scene == null:
		printerr("Layout not found")
	
	return layout_scene
