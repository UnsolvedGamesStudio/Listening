extends Node
class_name MainScene

@export_enum("hub_world", "layout", "test_level") var scene_to_load:= "title_screen"
@export var level_layout_to_load:= preload("uid://bx7u442mlk4wi")
@export var default_song:= preload("uid://bv4fypx7ab87u")
@export var always_start_bgm:= false
