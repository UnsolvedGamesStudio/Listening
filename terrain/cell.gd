extends Node3D
class_name Cell


var occupants: Array[Node3D]

var cell_grid_position: Vector2i = Vector2.ZERO

@onready var top_face: MeshInstance3D = %TopFace
@onready var north_face: MeshInstance3D = %NorthFace
@onready var east_face: MeshInstance3D = %EastFace
@onready var south_face: MeshInstance3D = %SouthFace
@onready var west_face: MeshInstance3D = %WestFace
@onready var bottom_face: MeshInstance3D = %BottomFace

@onready var cell_collision: CellCollision = $CellCollision


func _ready() -> void:
	cell_collision.area_entered.connect(on_area_entered)
	cell_collision.area_exited.connect(on_area_exited)


func update_faces(cell_list: Array, cell_size: int) -> void:
	cell_grid_position = Vector2i(position.x / cell_size as int, position.z / 2 as int)
	Vars.cell_coordinates.append(cell_grid_position)
	
	if cell_list.has(cell_grid_position + Vector2i.UP):
		north_face.queue_free()
	
	if cell_list.has(cell_grid_position + Vector2i.RIGHT):
		east_face.queue_free()
	
	if cell_list.has(cell_grid_position + Vector2i.DOWN):
		south_face.queue_free()
	
	if cell_list.has(cell_grid_position + Vector2i.LEFT):
		west_face.queue_free()


func add_occupant(area: Area3D):
	if area.owner is not Player and area.owner is not Enemy:
		return
	
	occupants.append(area.owner)


func remove_occupant(area: Area3D):
	occupants.erase(area.owner)


func on_area_entered(area: Area3D):
	if not area.is_in_group("player_collision") and not area.is_in_group("enemy_collision"):
		return
	
	add_occupant(area)
	
	if area.is_in_group("player_collision"):
		Vars.player_cell = self
	
	if area.is_in_group("enemy_collision"):
		if not "owner" in area:
			return
		
		if not "occupied_cell" in area.owner:
			return
		
		area.owner.occupied_cell = self


func on_area_exited(area: Area3D):
	remove_occupant(area)
