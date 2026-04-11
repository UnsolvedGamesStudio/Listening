extends Node3D
class_name Cell

@onready var cell_collision: CellCollision = $CellCollision

@export var max_player_height:= 4.0

var occupants: Array[Node3D]

var forgotten:= false
var starting_floor:= -1
var cell:= self

enum WallSide { NORTH, EAST, SOUTH, WEST }
var walls: Dictionary = {
	WallSide.NORTH: false,
	WallSide.EAST: false,
	WallSide.SOUTH: false,
	WallSide.WEST: false
}


func _ready() -> void:
	await Bus.level_layout_ready
	
	cell_collision.area_entered.connect(on_area_entered)
	cell_collision.area_exited.connect(on_area_exited)
	
	if not SceneManager.is_current_scene(SceneManager.Scenes.HUB_WORLD):
		NavGraph.add_cell(self)


func add_occupant(occupant: Node):
	if is_valid_occupant(occupant) == false:
		return
	
	if occupant in occupants:
		return
	
	if occupant is Player:
		Vars.player_cell = self
	
	if "occupied_cell" in occupant:
		occupant.occupied_cell = self
	
	NavGraph.set_point_weight(global_position, 3.0)
	
	occupants.append(occupant)


func remove_occupant(occupant: Node):
	if not occupant in occupants:
		return
	
	NavGraph.set_point_weight(global_position, 1.0)
	
	occupants.erase(occupant)


func is_valid_occupant(occupant: Node):
	if occupant is Player:
		return true 
	
	if occupant is Enemy:
		return true 
	
	if occupant.is_in_group("obstacle"):
		return true 
	
	return false


func is_cell_blocked(ignore: Array = []) -> bool:
	for occupant in occupants:
		if occupant in ignore:
			continue  # skip ignored entities
		
		return true  # any other occupant blocks the cell
	
	return false

# Registers a wall on this cell by determining which side
# (NORTH, SOUTH, EAST, WEST) it occupies.
# Works with rotated cells, assumes walls are zero-thickness planes.
func register_wall(wall: Node):
	# Convert wall position into cell-local space
	var local_pos = global_transform.basis.inverse() * (wall.global_position - global_position)
	
	# Use wall orientation to determine which axis it’s blocking
	# Assuming wall’s local +Z is its "forward"
	var local_forward = global_transform.basis.inverse() * wall.global_transform.basis.z
	
	var side: int
	
	if abs(local_forward.x) > abs(local_forward.z):
		# Wall is roughly aligned along the x-axis → blocks EAST/WEST
		side = Cell.WallSide.EAST if local_pos.x > 0 else Cell.WallSide.WEST
	else:
		# Wall is roughly aligned along the z-axis → blocks NORTH/SOUTH
		side = Cell.WallSide.SOUTH if local_pos.z > 0 else Cell.WallSide.NORTH
	
	walls[side] = true


func unregister_wall(wall: Node):
	# Convert wall position into cell-local space
	var local_pos = global_transform.basis.inverse() * (wall.global_position - global_position)
	
	# Use wall orientation to determine which axis it’s blocking
	# Assuming wall’s local +Z is its "forward"
	var local_forward = global_transform.basis.inverse() * wall.global_transform.basis.z
	
	var side: int
	
	if abs(local_forward.x) > abs(local_forward.z):
		# Wall is roughly aligned along the x-axis → blocks EAST/WEST
		side = Cell.WallSide.EAST if local_pos.x > 0 else Cell.WallSide.WEST
	else:
		# Wall is roughly aligned along the z-axis → blocks NORTH/SOUTH
		side = Cell.WallSide.SOUTH if local_pos.z > 0 else Cell.WallSide.NORTH
	
	NavGraph.update_point_connections(global_position)
	
	walls[side] = false


func _exit_tree() -> void:
	var world_x:= roundi(global_position.x / Vars.cell_size) 
	var world_z:= roundi(global_position.z / Vars.cell_size) 
	var world_pos:= Vector2i(world_x, world_z)


func on_area_entered(area: Area3D):
	if area.owner.is_in_group("wall"):
		register_wall(area.owner)
	
	add_occupant(area.owner)


func on_area_exited(area: Area3D):
	if not is_instance_valid(area):
		return
	
	if not is_instance_valid(area.owner):
		return
	
	if area.owner.is_in_group("wall"):
		unregister_wall(area.owner)
	
	remove_occupant(area.owner)
