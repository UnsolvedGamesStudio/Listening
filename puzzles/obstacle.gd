extends Node3D
class_name Obstacle

@onready var faces: Node3D = %Faces

var impassable:= true
var occupied_cell: Cell


func turn_off_faces():
	for face in faces.get_children():
		if not face.has_method("turn_off"):
			continue
		
		face.turn_off()
	
	NavGraph.rebuild_cell_connections(occupied_cell.global_position, true, [Find.P()])
