extends Node
class_name MainScene

@export_group("Debug Options")
@export var scene_to_load: SceneManager.Scenes = SceneManager.Scenes.TITLE_SCREEN
@export var default_blueprint:= preload("uid://bqk51arvtg2x")
@export var default_song:= preload("uid://bv4fypx7ab87u")
@export var prevent_saving:= false
@export var always_start_bgm:= false
