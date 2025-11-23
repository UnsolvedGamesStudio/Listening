extends Node3D
class_name Cell

@onready var cell_collision: CellCollision = $CellCollision
@onready var north_cell_detect: RayCast3D = %NorthCellDetect
@onready var east_cell_detect: RayCast3D = %EastCellDetect
@onready var south_cell_detect: RayCast3D = %SouthCellDetect
@onready var west_cell_detect: RayCast3D = %WestCellDetect

@export var max_player_height:= 10.0

var occupants: Array[Node3D]
var cell_grid_position: Vector2i = Vector2i(42069, 42069)

var cell:= self


func _ready() -> void:
	cell_collision.area_entered.connect(on_area_entered)
	cell_collision.area_exited.connect(on_area_exited)


func get_adjacent_cells():
	var adjacent_cells: Array[Cell]
	var y_pos:= 0.0
	var detected
	
	detected = check_cell_detect(north_cell_detect)
	if not detected == null:
		adjacent_cells.append(detected)
	
	detected = check_cell_detect(east_cell_detect)
	if not detected == null:
		adjacent_cells.append(detected)
	
	detected = check_cell_detect(south_cell_detect)
	if not detected == null:
		adjacent_cells.append(detected)
	
	detected = check_cell_detect(west_cell_detect)
	if not detected == null:
		adjacent_cells.append(detected)
	
	return adjacent_cells


func check_cell_detect(cell_detect):
	if cell_detect == null:
		return
	
	if cell_detect.get_collider() == null:
		return null
	
	if cell_detect.get_collider().owner.is_in_group("cell"):
		return cell_detect.get_collider().owner


func add_occupant(occupant: Node):
	if occupant in occupants:
		return
	
	occupants.append(occupant)


func remove_occupant(occupant: Node):
	if not occupant in occupants:
		return
	
	occupants.erase(occupant)


func handle_gridless():
	if not cell_grid_position == Vector2i(42069, 42069):
		return
	
	var world_x:= roundi(global_position.x / Vars.cell_size) 
	var world_z:= roundi(global_position.z / Vars.cell_size) 
	var world_pos:= Vector2i(world_x, world_z)
	cell_grid_position = world_pos


func _exit_tree() -> void:
	var world_x:= roundi(global_position.x / Vars.cell_size) 
	var world_z:= roundi(global_position.z / Vars.cell_size) 
	var world_pos:= Vector2i(world_x, world_z)


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
