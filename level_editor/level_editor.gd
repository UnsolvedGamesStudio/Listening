extends Node
class_name LevelEditorBlueprint
## Todo: make a tool button that creates a packed scene
@export var remembering_costs: Array[int] = [10, 20, 30, 40]
@export var unique_objects: Array[PackedScene] = []


func _ready() -> void:
	for child in get_children():
		if not child.has_method("hide"):
			return
		
		child.hide()
