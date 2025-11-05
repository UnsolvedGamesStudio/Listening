extends Resource
class_name LevelData

@export var level_blueprint:= preload("uid://ccywvjqsju55m")
@export var level_name:= "name"
@export var required_synapses:= 0

@export_category("Theme")
@export var songs: Array[AudioStream] = []

@export var wall_texture:= preload("uid://b4s6ykblvadm")
@export var floor_texture:= preload("uid://b4s6ykblvadm")
@export var ceiling_texture:= preload("uid://b4s6ykblvadm")
