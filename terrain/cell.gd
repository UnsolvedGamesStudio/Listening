extends Node3D
class_name Cell


var occupants: Array[Node3D]

@onready var top_face: MeshInstance3D = %TopFace
@onready var north_face: MeshInstance3D = %NorthFace
@onready var east_face: MeshInstance3D = %EastFace
@onready var south_face: MeshInstance3D = %SouthFace
@onready var west_face: MeshInstance3D = %WestFace
@onready var bottom_face: MeshInstance3D = %BottomFace


func update_faces(cell_list: Array, cell_size: int) -> void:
	var my_grid_position = Vector2i(position.x / cell_size as int, position.z / 2 as int)
	
	if cell_list.has(my_grid_position + Vector2i.UP):
		north_face.queue_free()
	
	if cell_list.has(my_grid_position + Vector2i.RIGHT):
		east_face.queue_free()
	
	if cell_list.has(my_grid_position + Vector2i.DOWN):
		south_face.queue_free()
	
	if cell_list.has(my_grid_position + Vector2i.LEFT):
		west_face.queue_free()
