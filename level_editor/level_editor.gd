extends Node
class_name LevelEditorBlueprint
## Todo: make a tool button that creates a packed scene
## Todo: build a signal-based event/trigger system for the level editor to use
@export var remembering_costs: Array[int] = [10, 20, 30, 40]
@export var unique_objects: Array[PackedScene] = []

@export_category("Music Box Contents")
@export var box_1: Array[PackedScene] = []
@export var box_2: Array[PackedScene] = []
@export var box_3: Array[PackedScene] = []
@export var box_4: Array[PackedScene] = []
@export var box_5: Array[PackedScene] = []
@export var box_6: Array[PackedScene] = []
@export var box_7: Array[PackedScene] = []
@export var box_8: Array[PackedScene] = []
@export var box_9: Array[PackedScene] = []
@export var box_10: Array[PackedScene] = []

var box_arrays: Array[Array] = [box_1, box_2, box_3, box_4, box_5, box_6, box_7, box_8, box_9, box_10]


func _ready() -> void:
	for child in get_children():
		if not child.has_method("hide"):
			return
		
		child.hide()


func init_box_arrays():
	box_arrays = [box_1, box_2, box_3, box_4, box_5, box_6, box_7, box_8, box_9, box_10]
