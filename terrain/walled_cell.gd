extends Node3D
class_name WalledCell


@onready var top_face: Node3D = %TopFace
@onready var north_face: Node3D = %NorthFace
@onready var east_face: Node3D = %EastFace
@onready var south_face: Node3D = %SouthFace
@onready var west_face: Node3D = %WestFace
@onready var bottom_face: Node3D = %BottomFace

@onready var cell: Cell = %BottomFace.get_child(0)

var cell_grid_position: Vector2i = Vector2.ZERO


func update_faces(cell_list: Array, cell_size: float) -> void:
	if cell_list.has(cell_grid_position + Vector2i.UP):
		north_face.queue_free()
	
	if cell_list.has(cell_grid_position + Vector2i.RIGHT):
		east_face.queue_free()
	
	if cell_list.has(cell_grid_position + Vector2i.DOWN):
		south_face.queue_free()
	
	if cell_list.has(cell_grid_position + Vector2i.LEFT):
		west_face.queue_free()
