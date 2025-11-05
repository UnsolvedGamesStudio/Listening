extends Node3D
class_name LevelLoader
## Todo: Add a skybox to the hubworld
## Todo: Make a pre-level screen, with song selection and collectibles acquired
## Todo: add an indicator of required synapses
@onready var level_name_label: Label = %LevelNameLabel
@onready var area_3d: Area3D = %Area3D

@export var level_data: LevelData


func _ready() -> void:
	level_name_label.text = level_data.level_name
	area_3d.area_entered.connect(on_area_3d_area_entered)


func load_level():
	var blueprint = level_data.level_blueprint
	SceneManager.current_blueprint = blueprint
	SceneManager.switch_scene("layout")


func on_area_3d_area_entered(area: Area3D):
	load_level()
