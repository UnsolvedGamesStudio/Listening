@tool
extends Node3D
class_name WalledCell

@onready var north_face: Node3D = %NorthFace
@onready var east_face: Node3D = %EastFace
@onready var south_face: Node3D = %SouthFace
@onready var west_face: Node3D = %WestFace
@onready var bottom_face: Node3D = %BottomFace

@onready var cell: Cell = %BottomFace.get_child(0)


func _ready() -> void:
	toggle_visibility()
	
	if Engine.is_editor_hint():
		return
	
	await Bus.level_done_generating
	
	update_faces()


func update_faces() -> void:
	var cell_list:= Find.all_cell_positions()
	var forward_cell:= Vector3(cell.global_position + (Vector3.FORWARD * Vars.cell_size))
	var right_cell:= Vector3(cell.global_position + (Vector3.RIGHT * Vars.cell_size))
	var back_cell:= Vector3(cell.global_position + (Vector3.BACK * Vars.cell_size))
	var left_cell:= Vector3(cell.global_position + (Vector3.LEFT * Vars.cell_size))
	
	if cell_list.has(forward_cell):
		north_face.queue_free()
	
	if cell_list.has(right_cell):
		east_face.queue_free()
	
	if cell_list.has(back_cell):
		south_face.queue_free()
	
	if cell_list.has(left_cell):
		west_face.queue_free()


func toggle_visibility():
	var walls:= [north_face, east_face, south_face, west_face]
	
	var in_editor:= Engine.is_editor_hint()
	
	for wall in walls:
		if in_editor == true:
			wall.visible = false
		else:
			wall.visible = true
