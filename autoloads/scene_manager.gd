extends Node
## Todo: preloads should be loaded at the relevant time by category, shown on the loading screen
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
	
	call_deferred("change_scene", main.scene_to_load)


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
			_instantiate_after_loading()
			loading_in_progress = false


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
	
	Vars.reset()
	
	path_being_loaded = path
	loading_in_progress = true
	current_loading_progress = 0.0
	last_loading_progress = 0.0
	active_scene_name = scene_path
	loading_thread_started.emit(scene_path)
	
	ResourceLoader.load_threaded_request(path)
	
	if needs_loading_screen(active_scene_name) and LoadingScreen.finished == true:
		LoadingScreen.start()


func reload_level():
	change_scene(active_scene_name)


func _instantiate_after_loading():
	var packed_scene: PackedScene = ResourceLoader.load_threaded_get(path_being_loaded)
	
	_remove_previous_scene()
	
	if active_scene_instance:
		await active_scene_instance.tree_exited
	
	if needs_loading_screen(active_scene_name) and LoadingScreen.finished == false:
		await Bus.loading_screen_finished
	
	loading_in_progress = false
	
	if packed_scene == null:
		push_error("PackedScene: ", path_being_loaded, " is null after loading")
		return
	
	
	var scene_inst: Node = packed_scene.instantiate()
	
	main.add_child(scene_inst)
	active_scene_instance = scene_inst
	
	LevelGenerator.activate()
	Filters.fade_in()
	
	if scene_inst.is_in_group("layout"):
		Bgm.start_song()
	
	Bus.level_layout_ready.emit()


func needs_loading_screen(scene: Scenes):
	if scene_paths[scene]["type"] == SceneTypes.UI:
		return false
	
	return true


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
