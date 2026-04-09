extends Node3D
class_name LevelLoader
## Todo: Add a skybox to the hubworld
## Todo: Make a pre-level screen, with song selection and collectibles acquired, and equip choices
## Todo: add an indicator of required synapses
## Todo: allow color customization
@onready var level_name_label: Label = %LevelNameLabel
@onready var area_3d: Area3D = %Area3D

@export var enabled:= true
@export var level_data: LevelData


func _ready() -> void:
	level_name_label.text = level_data.level_name
	area_3d.area_entered.connect(on_area_3d_area_entered)


func load_level():
	if enabled == false:
		return
	
	var blueprint = level_data.level_blueprint
	LevelGenerator.current_blueprint = blueprint
	
	SceneManager.change_scene(SceneManager.Scenes.PREP_SCREEN)


func on_area_3d_area_entered(area: Area3D):
	if not area.owner is Player:
		return
	
	area.owner.can_act = false
	area.owner.can_look = false
	load_level()
