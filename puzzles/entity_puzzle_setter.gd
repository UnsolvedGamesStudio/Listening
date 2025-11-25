extends Node3D
class_name PuzzleSetter

@onready var area_3d: Area3D = %Area3D
@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D

static var registered_enemies:= []

var puzzle_id:= -1
var active:= true


func _ready() -> void:
	set_collision_size()
	area_3d.area_entered.connect(on_area_3d_area_entered)
	await get_tree().create_timer(0.2).timeout
	active = false


func set_collision_size():
	collision_shape_3d.shape.size.x = Vars.cell_size - 0.01
	collision_shape_3d.shape.size.z = Vars.cell_size - 0.01


func on_area_3d_area_entered(area: Area3D):
	if active == false:
		return
	
	if "puzzle_id" in area.owner:
		area.owner.puzzle_id = puzzle_id
