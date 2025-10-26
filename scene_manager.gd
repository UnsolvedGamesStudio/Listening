extends Node

var main: Node
var current_scene: Node

var scenes: Dictionary[String, PackedScene] = {
	"layout": preload("uid://d1rnngxhnemng"),
}


func _ready() -> void:
	main = get_tree().get_first_node_in_group("main_scene")
	load_game()


func load_game():
	var layout_scene_inst:= scenes["layout"].instantiate()
	
	main.add_child(layout_scene_inst)
	current_scene = layout_scene_inst


func reload_game():
	if current_scene == null:
		return
	
	current_scene.queue_free()
	Vars.reset()
	load_game()
