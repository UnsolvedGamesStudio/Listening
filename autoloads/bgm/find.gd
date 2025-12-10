extends Node


func P() -> Player:
	var player_scene:= get_tree().get_first_node_in_group("player")
	
	if player_scene == null:
		printerr("Player not found")
	
	return player_scene


func layout() -> Node:
	var layout_scene:= get_tree().get_first_node_in_group("playable_level")
	
	if layout_scene == null:
		printerr("Layout not found")
	
	return layout_scene


func all_cells() -> Array[Node]:
	var cell_scenes:= get_tree().get_nodes_in_group("cell")
	
	if cell_scenes == []:
		printerr("No cell scene found")
	
	return cell_scenes


func all_cell_positions() -> Array[Vector3]:
	var cell_scenes:= get_tree().get_nodes_in_group("cell")
	var cell_positions: Array[Vector3] = []
	
	if cell_scenes == []:
		printerr("No cell scene found")
	
	for cell in cell_scenes:
		cell_positions.append(cell.global_position)
	
	return cell_positions
