extends Node
#var user_path:= "user://save_data/save_data.json"
var json_path:= "res://save_data/save_data.json"

var _saved_data:= {
	"synapses" : {},
	"neurons" : {},
}


func _ready() -> void:
	if not FileAccess.file_exists(json_path):
		write_save_data()
	
	if read_save_data() == {}:
		write_save_data()
	
	load_save_data()
	
	Bus.loading_level.connect(on_loading_level)


## Todo: If file is blank, initialize the dict
func write_save_data():
	var file = FileAccess.open(json_path, FileAccess.ModeFlags.WRITE)
	
	if file == null:
		printerr(self, ": Unable to write json file, no file found")
		return
	
	var json_text:= JSON.stringify(_saved_data, "\t")
	
	file.store_string(json_text)


func load_save_data():
	if not FileAccess.file_exists(json_path):
		printerr(self, " : No save file found")
		return
	
	var file = FileAccess.open(json_path, FileAccess.READ)
	var json_text = file.get_as_text()
	var parsed_text = JSON.parse_string(json_text)
	
	if _saved_data == null:
		printerr(self, ": parsed json data is null")
		return
	
	_saved_data = parsed_text


func read_save_data():
	if not FileAccess.file_exists(json_path):
		printerr(self, " : No save file found")
		return
	
	var file = FileAccess.open(json_path, FileAccess.READ)
	var json_text = file.get_as_text()
	var parsed_text = JSON.parse_string(json_text)
	
	return parsed_text


func set_collected(category: String, save_id: String):
	_saved_data.get_or_add(category, {})
	_saved_data[category].get_or_add(save_id, true)


func check_node_collected(object, inst_save_id):
	if not "category" in object:
		return false
	
	if check_id_collected(object.category, inst_save_id) == true:
		return true
	
	return false


func check_id_collected(category: String, save_id: String):
	if not category in _saved_data:
		_saved_data[category] = {}
		return false
	
	if not save_id in _saved_data[category]:
		return false
	
	return true


func get_collected_amount(category: String) -> int:
	if not category in _saved_data:
		return 0
	
	return _saved_data[category].size()


func erase_all_save_data():
	print("Data erased")
	_saved_data.clear()
	write_save_data()


func on_loading_level():
	load_save_data()
