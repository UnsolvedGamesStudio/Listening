extends Node
## Todo: Make second dict for save cache
## Todo: Take current level/scene into account
enum DataType {NEURONS, SYNAPSES, REMEMBERERS, FORGETTERS}

var json_path:= "user://psychodrama_save_data.json"

var _saved_data:= {}



func _ready() -> void:
	if OS.has_feature("editor"):
		json_path = "res://debug_save_file.json"
	
	if not FileAccess.file_exists(json_path):
		write_save_data()
	
	if read_save_data() == {}:
		write_save_data()
	
	load_save_data()
	
	Bus.game_lost.connect(on_game_lost)
	Bus.loading_level.connect(on_loading_level)


## Todo: If file is blank, initialize the dict
func write_save_data():
	if get_tree().get_first_node_in_group("main_scene").prevent_saving == true:
		return
	
	var file = FileAccess.open(json_path, FileAccess.ModeFlags.WRITE)
	
	if file == null:
		push_error(self, ": Unable to write json file, no file found")
		return
	
	var json_text:= JSON.stringify(_saved_data, "\t")
	
	file.store_string(json_text)


func load_save_data():
	if not FileAccess.file_exists(json_path):
		push_error(self, " : No save file found")
		return
	
	var file = FileAccess.open(json_path, FileAccess.READ)
	var json_text = file.get_as_text()
	var parsed_text = JSON.parse_string(json_text)
	
	if _saved_data == null:
		push_error(self, ": parsed json data is null")
		return
	
	_saved_data = parsed_text


func read_save_data():
	if not FileAccess.file_exists(json_path):
		push_error(self, " : No save file found")
		return
	
	var file = FileAccess.open(json_path, FileAccess.READ)
	var json_text = file.get_as_text()
	var parsed_text = JSON.parse_string(json_text)
	
	return parsed_text


func save_position(category: DataType, position: Vector3):
	var save_id:= str(position.x, "_", position.y, "_", position.z)
	
	set_collected(category, save_id)


func set_collected(category: DataType, save_id: String):
	if not str(category) in _saved_data:
		_saved_data[str(category)] = {}
	
	if not save_id in _saved_data[str(category)]:
		_saved_data[str(category)][save_id] = true


func check_node_collected(object, inst_save_id):
	if not "category" in object:
		return false
	
	if check_id_collected(object.category, inst_save_id) == true:
		return true
	
	return false


func position_collected(category: DataType, position: Vector3):
	var save_id:= str(position.x, "_", position.y, "_", position.z)
	
	return check_id_collected(category, save_id)


func check_id_collected(category: DataType, save_id: String):
	if not str(category) in _saved_data:
		return false
	
	if not str(save_id) in _saved_data[str(category)]:
		return false
	
	return true


func get_collected_amount(category: DataType) -> int:
	if not str(category) in _saved_data:
		return 0
	
	return _saved_data[str(category)].size()


func erase_all_save_data():
	print("Data erased")
	_saved_data.clear()
	write_save_data()


func on_game_lost():
	pass


func on_loading_level():
	load_save_data()
