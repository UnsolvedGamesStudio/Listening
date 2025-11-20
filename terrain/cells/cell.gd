extends Node3D
class_name Cell

@onready var cell_collision: CellCollision = $CellCollision

@export var max_player_height:= 10.0

var occupants: Array[Node3D]
var cell_grid_position: Vector2i = Vector2.ZERO

var cell:= self


func _ready() -> void:
	cell_collision.area_entered.connect(on_area_entered)
	cell_collision.area_exited.connect(on_area_exited)


func add_occupant(occupant: Node):
	if occupant in occupants:
		return
	
	occupants.append(occupant)


func remove_occupant(occupant: Node):
	if not occupant in occupants:
		return
	
	occupants.erase(occupant)


func on_area_entered(area: Area3D):
	if not area.is_in_group("player_collision") and not area.is_in_group("enemy_room_notifier")\
	and not area.is_in_group("obstacle_collision"):
		return
	
	add_occupant(area.owner)
	
	if area.is_in_group("player_collision"):
		Vars.player_cell = self
	
	if area.is_in_group("enemy_room_notifier") or area.is_in_group("obstacle_collision") :
		if not "occupied_cell" in area.owner:
			return
		
		area.owner.occupied_cell = self


func on_area_exited(area: Area3D):
	remove_occupant(area.owner)
