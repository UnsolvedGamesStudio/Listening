extends Node

var main: MainScene
var active_scene_name: Scenes
var active_scene_instance: Node

var first_load:= true

var path_being_loaded:= ""

var loading_in_progress:= false
var current_loading_progress:= 0.0
var last_loading_progress:= 0.0

var progress_percentage:= 0.0

enum Scenes {
	TITLE_SCREEN,
	LAYOUT,
	TEST_LEVEL,
	HUB_WORLD,
	PREP_SCREEN,
}

enum SceneTypes {
	UI,
	BLUEPRINT,
	PREBUILT,
	CUTSCENE,
}

var scene_paths: Dictionary = {
	Scenes.TITLE_SCREEN : {"path" :"uid://bqk51arvtg2x", "type" : SceneTypes.UI},
	Scenes.TEST_LEVEL : {"path" :"uid://d4kapwpdawyhh", "type" : SceneTypes.PREBUILT},
	Scenes.HUB_WORLD : {"path" :"uid://bb0is713hmgcy", "type" : SceneTypes.PREBUILT},
	Scenes.PREP_SCREEN : {"path" :"uid://cglbfa3a2dw7v", "type" : SceneTypes.UI},
	Scenes.LAYOUT : {"path" :"uid://d1rnngxhnemng", "type" : SceneTypes.BLUEPRINT},
}

signal loading_thread_started(scene: Scenes)
signal loading_progress_step(progress: float)
signal loading_thread_finished


func _ready() -> void:
	main = get_tree().get_first_node_in_group("main_scene")
	
	if main == null:
		push_error("MainScene node not found")
		return
	
	Bus.loading_screen_finished.connect(on_loading_screen_finished)
	var first_scene_to_instantiate = main.scene_to_load
	call_deferred("change_scene", first_scene_to_instantiate)


func _process(delta):
	if not loading_in_progress:
		return
	
	var progress:= []
	var status:= ResourceLoader.load_threaded_get_status(path_being_loaded, progress)
	
	current_loading_progress = progress[0]
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			loading_progress_step.emit(current_loading_progress)
			return
		
		ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Failed to load scene: %s" % path_being_loaded)
			loading_in_progress = false
			return
		
		ResourceLoader.THREAD_LOAD_LOADED:
			loading_thread_finished.emit()
			loading_in_progress = false


func _instantiate_after_loading():
	var packed_scene: PackedScene = ResourceLoader.load_threaded_get(path_being_loaded)
	
	loading_in_progress = false
	print(path_being_loaded)
	if packed_scene == null:
		push_error("PackedScene: ", path_being_loaded, " is null after loading")
		return
	
	_remove_previous_scene()
	
	var scene_inst: Node = packed_scene.instantiate()
	
	main.add_child(scene_inst)
	active_scene_instance = scene_inst
	
	LevelGenerator.activate()
	Filters.fade_in()
	
	if scene_inst.is_in_group("layout"):
		Bgm.start_song()
	
	Bus.level_layout_ready.emit()


func change_scene(scene_path: Scenes):
	var path: String = scene_paths[scene_path]["path"]
	
	if loading_in_progress:
		push_warning("SceneManager is already loading a scene")
		return
	
	if first_load == false:
		Filters.fade_out()
		await Bus.fade_out_ended
	
	if first_load == true:
		first_load = false
	
	path_being_loaded = path
	loading_in_progress = true
	current_loading_progress = 0.0
	active_scene_name = scene_path
	loading_thread_started.emit(scene_path)
	ResourceLoader.load_threaded_request(path)


func _remove_previous_scene():
	if not is_instance_valid(active_scene_instance):
		return
	
	if active_scene_instance == null:
		return
	
	active_scene_instance.queue_free()


func is_current_scene(scene: Scenes):
	if active_scene_name == scene:
		return true
	
	return false


func hide_node_in_hub(node: Node, scene: Scenes):
	if node == null:
		return
	
	if active_scene_name == scene:
		node.hide()
	else:
		node.show()


func quit_game():
	SaveManager.write_save_data()
	get_tree().quit()


func on_loading_screen_finished():
	print("moqifghnk")
	_instantiate_after_loading()


#var main: MainScene
#var current_scene: Node
#var current_blueprint: PackedScene
#
#enum scenes {
	#TITLE_SCREEN,
	#LAYOUT,
	#TEST_LEVEL,
	#HUB_WORLD,
	#PREP_SCREEN,
#}
#
#var next_scene: scenes
#
#
#func _ready() -> void:
	#process_mode = Node.PROCESS_MODE_ALWAYS
	#main = get_tree().get_first_node_in_group("main_scene")
	#
	#if main == null:
		#return
	#
	#load_debug()
	#
	#next_scene = main.scene_to_load
	#load_scene()
#
#
#func load_debug():
	#load_default_song()
	#current_blueprint = main.level_layout_to_load
#
#
#func load_default_song():
	#if main.default_song == null:
		#return
	#
	#var song_file:= main.default_song.file_path
	#var midi_file:= main.default_song.file_path
	#
	#if ResourceLoader.exists(song_file):
		#Bgm.stream = load(main.default_song.file_path)
	#
	#if ResourceLoader.exists(midi_file):
		#Bgm.midi_player.file = main.default_song.chords_midi_path
	#
	#Bgm.rhythm_notifier.bpm = main.default_song.bpm
	#Bgm.volume_db = main.default_song.volume
#
#
#func load_scene():
	#Vars.reset()
	#var packed_scene: PackedScene = get_scene_for_state(next_scene)
	#
	#if is_scene_valid(packed_scene) == false:
		#return
	#
	#var scene_inst:= packed_scene.instantiate()
	#
	### Check if entering a level
	#if scene_inst.is_in_group("layout"):
		#Bus.loading_level.emit()
		#generate_blueprint(scene_inst)
	#
	### Check if entering the hub
	#if scene_inst.is_in_group("hub_world"):
		#Bus.level_exited.emit()
		#SaveManager.write_save_data()
	#
	#main.add_child(scene_inst)
	#current_scene = scene_inst
	#
	#Filters.fade.play("fade_in")
	#
	#if scene_inst.is_in_group("playable_level"):
		#entering_playable_level(scene_inst)
#
#
#func is_scene_valid(scene):
	#if scene == null:
		#push_error(self, ": Scene ", scenes.keys()[next_scene],  " not found")
		#get_tree().quit()
		#return false
	#
	#return true
#
#
#func entering_playable_level(scene_inst):
	#if scene_inst.is_in_group("layout"):
		#start_level()
		#LevelGenerator.activate()
	#
	#await scene_inst.ready
	#Bus.level_done_generating.emit()
	#Bus.level_layout_ready.emit()
#
#
#func start_level():
	#Bgm.bus = "BGM"
	#
	#if Bgm.playing == false:
		#Bgm.start_song()
#
#
#func switch_scene(scene: scenes, blueprint: String = "", level_data: LevelData = null):
	#current_scene.queue_free()
	#next_scene = scene
	#load_scene()
#
#
#func generate_blueprint(scene_inst: Node):
	#if current_blueprint == null:
		#return
	#
	#if not scene_inst.is_in_group("blueprint_layout"):
		#return
	#
	#var blueprint_inst = current_blueprint.instantiate()
	#
	#scene_inst.add_child(blueprint_inst)
#
#
#func reload_level():
	#if get_tree().paused == true:
		#get_tree().paused = false
	#
	#Engine.time_scale = 1.0
	#if current_scene == null:
		#return
	#
	#SceneManager.change_scene(SceneManager.Scenes.LAYOUT)
	#
	##current_scene.queue_free()
	##load_scene()
#
#
#func quit_game():
	#SaveManager.write_save_data()
	#get_tree().quit()
#
#
#func get_scene_for_state(scene: scenes):
	#var returned_scene: PackedScene
	#
	#if scene == scenes.TITLE_SCREEN:
		#returned_scene = preload("uid://bqk51arvtg2x")
	#
	#if scene == scenes.TEST_LEVEL:
		#returned_scene = preload("uid://ut6wqeoatv1w")
	#
	#if scene == scenes.HUB_WORLD:
		#returned_scene = preload("uid://bb0is713hmgcy")
	#
	#if scene == scenes.PREP_SCREEN:
		#returned_scene = preload("uid://cglbfa3a2dw7v")
	#
	#if scene == scenes.LAYOUT:
		#returned_scene = preload("uid://d1rnngxhnemng")
	#
	#return returned_scene
