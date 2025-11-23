extends Node3D
class_name Layout

@onready var level_generator: Node = %LevelGenerator

#var astar: AStarGrid2D
#
#
#func _ready() -> void:
	#var cells:= get_tree().get_nodes_in_group("cell")
	#var cell_size:= Vector2i(round(Vars.cell_size), round(Vars.cell_size))
	#astar = AStarGrid2D.new()
	#astar.cell_size = cell_size
	#astar.region = Rect2i(0, 0, cell_size.x, cell_size.y)
	#print(astar.region)
