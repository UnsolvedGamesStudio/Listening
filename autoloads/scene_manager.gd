extends Node
## Todo: turn dict strigs into enum
## Todo: load premade scenes like hub world instead of preload
## Todo: Create a state machine for the game's states: title screen, generating level, playing level, etc
var main: MainScene
var current_scene: Node
var current_blueprint: PackedScene

enum scenes {
	TITLE_SCREEN,
	LAYOUT,
	TEST_LEVEL,
	HUB_WORLD,
	PREP_SCREEN,
}

var next_scene: scenes


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	main = get_tree().get_first_node_in_group("main_scene")
	
	if main == null:
		return
	
	load_debug()
	
	next_scene = main.scene_to_load
	load_scene()


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


func load_scene():
	Vars.reset()
	var packed_scene: PackedScene = get_scene_for_state(next_scene)
	
	if is_scene_valid(packed_scene) == false:
		return
	
	var scene_inst:= packed_scene.instantiate()
	
	## Check if entering a level
	if scene_inst.is_in_group("layout"):
		Bus.loading_level.emit()
		generate_blueprint(scene_inst)
	
	## Check if entering the hub
	if scene_inst.is_in_group("hub_world"):
		Bus.level_exited.emit()
		SaveManager.write_save_data()
	
	main.add_child(scene_inst)
	current_scene = scene_inst
	
	Filters.fade.play("fade_in")
	
	if scene_inst.is_in_group("playable_level"):
		entering_playable_level(scene_inst)


func is_scene_valid(scene):
	if scene == null:
		push_error(self, ": Scene ", scenes.keys()[next_scene],  " not found")
		get_tree().quit()
		return false
	
	return true


func entering_playable_level(scene_inst):
	if scene_inst.is_in_group("layout"):
		start_level()
		LevelGenerator.activate()
		await scene_inst.ready
	
	Bus.level_done_generating.emit()
	Bus.level_layout_ready.emit()


func start_level():
	Bgm.bus = "BGM"
	
	if Bgm.playing == false:
		Bgm.start_song()


func switch_scene(scene: scenes, blueprint: String = "", level_data: LevelData = null):
	current_scene.queue_free()
	next_scene = scene
	load_scene()


func generate_blueprint(scene_inst: Node):
	if current_blueprint == null:
		return
	
	if not scene_inst.is_in_group("blueprint_layout"):
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
	load_scene()


func quit_game():
	SaveManager.write_save_data()
	get_tree().quit()


func get_scene_for_state(scene: scenes):
	var returned_scene: PackedScene
	
	if scene == scenes.TITLE_SCREEN:
		returned_scene = preload("uid://bqk51arvtg2x")
	
	if scene == scenes.TEST_LEVEL:
		returned_scene = preload("uid://ut6wqeoatv1w")
	
	if scene == scenes.HUB_WORLD:
		returned_scene = preload("uid://bb0is713hmgcy")
	
	if scene == scenes.PREP_SCREEN:
		returned_scene = preload("uid://cglbfa3a2dw7v")
	
	if scene == scenes.LAYOUT:
		returned_scene = preload("uid://d1rnngxhnemng")
	
	return returned_scene
