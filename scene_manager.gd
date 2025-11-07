extends Node
## Todo: turn dict strigs into enum
var main: MainScene
var current_scene: Node
var current_blueprint: PackedScene
var next_scene: String

var scenes: Dictionary[String, PackedScene] = {
	"hub_world" : preload("uid://bb0is713hmgcy"),
	"layout" : preload("uid://d1rnngxhnemng"),
	"level" : preload("uid://cup1ntaax8sgg"),
	"title_screen" : preload("uid://bqk51arvtg2x"),
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	main = get_tree().get_first_node_in_group("main_scene")
	
	current_blueprint = main.level_layout_to_load
	
	next_scene = main.scene_to_load
	load_game()


func load_game():
	var scene_inst:= scenes[next_scene].instantiate()
	
	if scene_inst is Layout:
		generate_blueprint(scene_inst)
	
	main.add_child(scene_inst)
	current_scene = scene_inst
	
	Filters.fade.play("fade_in")
	
	if scene_inst is Layout:
		await Filters.fade.animation_finished
		start_level()


func start_level():
	Bgm.bus = "BGM"
	
	if Bgm.playing == false:
		Bgm.start_song()


func switch_scene(scene: String, blueprint: String = ""):
	current_scene.queue_free()
	next_scene = scene
	load_game()


func generate_blueprint(scene_inst: Node):
	if current_blueprint == null:
		return
	
	var blueprint_inst = current_blueprint.instantiate()
	
	scene_inst.add_child(blueprint_inst)


func reload_level():
	if get_tree().paused == true:
		get_tree().paused = false
	
	Engine.time_scale = 1.0
	if current_scene == null:
		return
	
	current_scene.queue_free()
	Vars.reset()
	load_game()
