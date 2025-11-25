extends Node3D
class_name EnemyObjectiveSetter

@onready var area_3d: Area3D = %Area3D
@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D

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


func set_enemy(area: Area3D):
	var enemy: Enemy = area.owner
	
	if not "puzzle_id" in enemy:
		return
	
	enemy.puzzle_id = puzzle_id
	
	if puzzle_id in TriggersManager.to_die_ids:
		TriggersManager.to_die_ids[puzzle_id] += 1
	else:
		TriggersManager.to_die_ids[puzzle_id] = 1


func on_area_3d_area_entered(area: Area3D):
	if active == false:
		return
	
	set_enemy(area)
