extends Node

var main: MainScene
var current_scene: Node
var next_scene: String


var scenes: Dictionary[String, PackedScene] = {
	"layout" : preload("uid://d1rnngxhnemng"),
	"level" : preload("uid://cup1ntaax8sgg"),
	"title_screen" : preload("uid://bqk51arvtg2x")
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	main = get_tree().get_first_node_in_group("main_scene")
	next_scene = main.scene_to_load
	load_game()


func switch_scene(scene: String):
	current_scene.queue_free()
	next_scene = scene
	load_game()


func load_game():
	var scene_inst:= scenes[next_scene].instantiate()
	
	main.add_child(scene_inst)
	current_scene = scene_inst
	if scene_inst.has_method("start_level"):
		scene_inst.start_level()


func reload_game():
	if get_tree().paused == true:
		get_tree().paused = false
	
	Engine.time_scale = 1.0
	if current_scene == null:
		return
	
	current_scene.queue_free()
	Vars.reset()
	load_game()
