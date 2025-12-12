extends Node
class_name MainScene

@export_group("Debug Options")
@export var scene_to_load: SceneManager.Scenes = SceneManager.Scenes.TITLE_SCREEN
@export var use_test_blueprint:= false
@export var test_blueprint:= preload("uid://d4kapwpdawyhh")
var default_blueprint:= preload("uid://bptiy4w2getxo")
@export var default_song:= preload("uid://bv4fypx7ab87u")
@export var prevent_saving:= false
@export var always_start_bgm:= false
