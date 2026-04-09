extends Node3D
class_name Forgetter
## Todo: Use group instead of Vars var
@onready var area_3d: Area3D = %Area3D
@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D
@onready var gpu_particles_3d: GPUParticles3D = %GPUParticles3D

var previously_collected:= false
var original_position:= Vector3.ZERO
var puzzle_id:= -1
var forgotten_nodes: Array[Node3D] = []
var remembered_nodes: Array[Node3D] = []


func _ready() -> void:
	Vars.forgetters.append(self)
	
	Bus.necessary_enemies_died.connect(necessary_enemies_died)
	area_3d.area_entered.connect(on_area_3d_area_entered)
	
	set_collision_size()
	
	await Bus.level_done_generating
	
	original_position = global_position
	
	if SaveManager.position_collected(SaveManager.DataType.FORGETTERS, global_position):
		previously_collected = true
	
	enter()
	
	deactivate_collision()



func enter():
	pass


func set_collision_size():
	collision_shape_3d.shape.size.x = Vars.cell_size - 0.01
	collision_shape_3d.shape.size.z = Vars.cell_size - 0.01


func forget_cell(area: Area3D):
	var cell = area.owner
	
	if not cell.owner.owner == null:
		forget(cell.owner.owner)
		return
	
	if not cell.owner == null:
		forget(cell.owner)
		return
	
	if cell is Cell:
		forget(cell)
		cell.forgotten = true
		return


func forget_entity(area: Area3D):
	if not area.owner is Node3D:
		return
	
	forget(area.owner)


func forget(object: Node3D):
	if object == null:
		push_error(self, " forget(): object not found")
		return
	
	if "enabled" in object:
		object.enabled = false
	
	object.hide()
	object.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	forgotten_nodes.append(object)


func remember():
	gpu_particles_3d.activate(0.2, false)
	
	for object: Node3D in forgotten_nodes:
		object.show()
		object.process_mode = Node.PROCESS_MODE_INHERIT
		
		if "enabled" in object:
			object.enabled = true
		
		if "forgotten" in object:
			object.forgotten = false
		
		remembered_nodes.append(object)
	
	SaveManager.save_position(SaveManager.DataType.FORGETTERS, global_position)
	forgotten_nodes.clear()


func deactivate_collision():
	await get_tree().create_timer(0.05).timeout
	
	area_3d.get_child(0).disabled = true


func necessary_enemies_died(enemy_puzzle_id: int):
	if not enemy_puzzle_id == puzzle_id:
		return
	
	remember()


func on_area_3d_area_entered(area: Area3D):
	if previously_collected == true:
		return
	
	if area.owner is RemembererPickup:
		return
	
	if area.owner is Cell:
		forget_cell(area)
	else:
		forget_entity(area)


func _exit_tree() -> void:
	if self in Vars.forgetters:
		Vars.forgetters.erase(self)
