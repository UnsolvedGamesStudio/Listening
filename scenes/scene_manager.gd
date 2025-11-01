extends Node
class_name SceneManager

@onready var fade: AnimationPlayer = %Fade

var main: Node
var current_scene: Node

var scenes: Dictionary[String, PackedScene] = {
	"layout" : preload("uid://d1rnngxhnemng"),
	"level" : preload("uid://cup1ntaax8sgg"),
	"title_screen" : preload("uid://bqk51arvtg2x")
}

@export_enum("level", "title_screen") var scene_to_load:= "layout"


func _ready() -> void:
	main = get_tree().get_first_node_in_group("main_scene")
	load_game()


func switch_scene(scene: String):
	current_scene.queue_free()
	scene_to_load = scene
	load_game()


func load_game():
	var layout_scene_inst:= scenes[scene_to_load].instantiate()
	
	main.add_child(layout_scene_inst)
	current_scene = layout_scene_inst


func reload_game():
	if current_scene == null:
		return
	
	current_scene.queue_free()
	Vars.reset()
	load_game()
