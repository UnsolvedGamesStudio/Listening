@tool
extends EditorPlugin

var tooltip_label: Label


func _enter_tree() -> void:
	main_screen_changed.connect(_on_main_screen_changed)
	
	tooltip_label = Label.new()
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.6)
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	tooltip_label.add_theme_stylebox_override("normal", style)
	
	get_editor_interface().get_base_control().add_child(tooltip_label)
	tooltip_label.hide()


func _exit_tree() -> void:
	if tooltip_label:
		tooltip_label.queue_free()


func _handles(object: Object) -> bool:
	var current_scene_root:= get_editor_interface().get_edited_scene_root()
	
	return current_scene_root is LevelEditorBlueprint


func _get_all_tilemaps() -> Array[Node]:
	var root = get_editor_interface().get_edited_scene_root()
	
	if not root:
		tooltip_label.hide()
		return []
	
	var tilemaps = root.find_children("*", "TileMapLayer", true, false)
	
	if tilemaps.size() > 0:
		tooltip_label.hide()
		return tilemaps
	
	return []


func _edit(object: Object) -> void:
	var current_scene_root:= get_editor_interface().get_edited_scene_root()
	
	if tooltip_label and current_scene_root is not LevelEditorBlueprint:
		tooltip_label.hide()


func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if not event is InputEventMouseMotion:
		return false
	
	var tilemaps = _get_all_tilemaps()
	var node_names: Array[String] = []
	
	if tilemaps.is_empty():
		tooltip_label.hide()
		return false
	
	for tilemap: TileMapLayer in tilemaps:
		if not tilemap or not tilemap.is_visible_in_tree():
			continue
		
		if not tilemap or not tilemap.is_visible_in_tree():
			continue
		
		var local_pos = tilemap.get_local_mouse_position()
		var cell = tilemap.local_to_map(local_pos)
		var data = tilemap.get_cell_tile_data(cell)
		
		if not data:
			continue
		
		var scene_resource = data.get_custom_data("scene")
		
		if not scene_resource:
			continue
		
		if not scene_resource.resource_path:
			continue
		
		var enemy_name = scene_resource.resource_path.get_file().get_basename().capitalize()
		
		if not enemy_name == "":
			node_names.append(str("• " + enemy_name))
		
		# Offset by 15 pixels down and right so the cursor doesn't cover the text
		tooltip_label.global_position = event.global_position + Vector2(15, 15)
		tooltip_label.reset_size()
		tooltip_label.show()
	
	if node_names.is_empty():
		tooltip_label.hide()
	else:
		tooltip_label.text = str("\n".join(node_names))
	
	return false


func _on_main_screen_changed(screen_name: String) -> void:
	if tooltip_label and screen_name != "2D":
		tooltip_label.hide()
