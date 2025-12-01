extends Node
## Todo: turn dict strigs into enum
## Todo: load premade scenes like hub world instead of preload
var main: MainScene
var current_scene: Node
var current_blueprint: PackedScene
var next_scene: String

var scenes: Dictionary[String, PackedScene] = {
	"hub_world" : preload("uid://bb0is713hmgcy"),
	"layout" : preload("uid://d1rnngxhnemng"),
	"level" : preload("uid://cup1ntaax8sgg"),
	"title_screen" : preload("uid://bqk51arvtg2x"),
	"prep_screen" : preload("uid://cglbfa3a2dw7v"),
	"test_level" : preload("uid://ut6wqeoatv1w"),
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	main = get_tree().get_first_node_in_group("main_scene")
	
	if main == null:
		return
	
	load_debug()
	
	next_scene = main.scene_to_load
	load_game()


func load_debug():
	load_default_song()
	current_blueprint = main.level_layout_to_load


func load_default_song():
	if main.default_song == null:
		return
	
	var song_file:= main.default_song.file_path
	var midi_file:= main.default_song.file_path
	
	if ResourceLoader.exists(song_file):
		Bgm.stream = load(main.default_song.file_path)
	
	if ResourceLoader.exists(midi_file):
		Bgm.midi_player.file = main.default_song.chords_midi_path
	
	Bgm.rhythm_notifier.bpm = main.default_song.bpm
	Bgm.volume_db = main.default_song.volume


func load_game():
	Vars.reset()
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
	load_game()
