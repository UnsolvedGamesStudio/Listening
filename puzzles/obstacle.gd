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
		
		if occupied_cell.occupants.has(self):
			occupied_cell.remove_occupant(self)

	#print(NavGraph.cell_to_id[occupied_cell.global_position])
	#
	#print(NavGraph.astar.get_point_connections(NavGraph.cell_to_id[occupied_cell.global_position]))
	#await get_tree().create_timer(0.5).timeout
	#print(NavGraph.astar.get_point_connections(NavGraph.cell_to_id[occupied_cell.global_position]))
	#NavGraph.rebuild_cell_connections(occupied_cell.global_position, true, [Find.P()])
	#await get_tree().create_timer(0.5).timeout
	#print(NavGraph.astar.get_point_connections(NavGraph.cell_to_id[occupied_cell.global_position]))
