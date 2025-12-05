extends Node3D
class_name Forgetter

@onready var area_3d: Area3D = %Area3D
@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D
@onready var gpu_particles_3d: GPUParticles3D = %GPUParticles3D

var puzzle_id:= -1
var active:= true
var forgotten_nodes: Array[Node3D] = []
var remembered_nodes: Array[Node3D] = []


func _ready() -> void:
	Vars.forgetters.append(self)
	set_collision_size()
	Bus.necessary_enemies_died.connect(necessary_enemies_died)
	area_3d.area_entered.connect(on_area_3d_area_entered)
	await get_tree().create_timer(0.25).timeout
	enter()
	active = false


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
		return


func forget_entity(area: Area3D):
	if not area.owner is Node3D:
		return
	
	forget(area.owner)


func forget(object: Node3D):
	if object == null:
		printerr(self, " forget(): object not found")
		return
	
	if "enabled" in object:
		object.enabled = false
	
	object.hide()
	object.process_mode = Node.PROCESS_MODE_DISABLED
	forgotten_nodes.append(object)


func remember():
	var test:= []
	gpu_particles_3d.activate(0.2, false)
	
	for object: Node3D in forgotten_nodes:
		object.show()
		object.process_mode = Node.PROCESS_MODE_INHERIT
		
		if "enabled" in object:
			object.enabled = true
		
		remembered_nodes.append(object)
		test.append(object)
	
	forgotten_nodes.clear()


func necessary_enemies_died(enemy_puzzle_id: int):
	if not enemy_puzzle_id == puzzle_id:
		return
	
	remember()


func on_area_3d_area_entered(area: Area3D):
	if active == false:
		return
	
	await get_tree().create_timer(0.25).timeout
	
	if area.owner is RemembererPickup:
		return
	
	if area.owner is Cell:
		forget_cell(area)
	else:
		forget_entity(area)


func _exit_tree() -> void:
	if self in Vars.forgetters:
		Vars.forgetters.erase(self)


#extends Node3D
#class_name Forgetter
#
#@onready var area_3d: Area3D = %Area3D
#@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D
#@onready var gpu_particles_3d: GPUParticles3D = %GPUParticles3D
#
#static var remember_count:= 0
#
#var puzzle_id:= -1
#var active:= true
#
#static var object_values: Dictionary[String, Dictionary] = {} ## {"id" : { "puzzle_id" int: , "node" node: , remembered : bool} }
#
#
#func _ready() -> void:
	#Vars.forgetters.append(self)
	#set_collision_size()
	#Bus.necessary_enemies_died.connect(necessary_enemies_died)
	#area_3d.area_entered.connect(on_area_3d_area_entered)
	#await get_tree().create_timer(0.25).timeout
	#enter()
	#active = false
#
#
#func enter():
	#pass
#
#
#func set_collision_size():
	#collision_shape_3d.shape.size.x = Vars.cell_size - 0.01
	#collision_shape_3d.shape.size.z = Vars.cell_size - 0.01
#
#
#func forget_cell(area: Area3D):
	#var cell = area.owner
	#
	#if not cell.owner.owner == null:
		#forget(cell.owner.owner)
		#return
	#
	#if not cell.owner == null:
		#forget(cell.owner)
		#return
	#
	#if cell is Cell:
		#forget(cell)
		#return
#
#
#func forget_entity(area: Area3D):
	#if not area.owner is Node3D:
		#return
	#
	#forget(area.owner)
#
#
#func forget(object: Node3D):
	#if object == null:
		#printerr(self, " forget(): object not found")
		#return
	#
	#if "enabled" in object:
		#object.enabled = false
	#
	#object.hide()
	#object.process_mode = Node.PROCESS_MODE_DISABLED
	#
	#var object_id:=  str(remember_count, "_", object.global_position.x, "_", object.global_position.y, "_", object.global_position.z)
	#
	#object_values[object_id] = {
		#"puzzle_id" : puzzle_id,
		#"node" : object,
		#"remembered" : false
	#}
#
#
#func remember():
	#gpu_particles_3d.activate(0.2, false)
	#triggered()
	#
	#for object in object_values:
		#var object_puzzle_id: int = object_values[object]["puzzle_id"]
		#prints(object_puzzle_id, puzzle_id)
		#if not object_puzzle_id == puzzle_id:
			#return
		#
		#var object_node: Node = object_values[object]["node"]
	#
		#object_node.show()
		#object_node.process_mode = Node.PROCESS_MODE_INHERIT
		#
		#if "enabled" in object_node:
			#object_node.enabled = true
		#
		#remember_count += 1
		#
		#object_values[object]["remembered"] = true
		#
		##save_remembered(object_node)
	#
	#remember_count = 0
#
#
#func triggered():
	#pass
#
#
#func object_is_saved(remembered_id):
	#pass
#
#
#func save_remembered(object):
	#SaveManager.set_collected("remembered_nodes", object_values.keys()[object])
#
#
#func necessary_enemies_died(enemy_puzzle_id: int):
	#if not enemy_puzzle_id == puzzle_id:
		#return
	#
	#remember()
#
#
#func on_area_3d_area_entered(area: Area3D):
	#if active == false:
		#return
	#
	#await get_tree().create_timer(0.25).timeout
	#
	#if area.owner is RemembererPickup:
		#return
	#
	#if area.owner is Cell:
		#forget_cell(area)
	#else:
		#forget_entity(area)
#
#
#func _exit_tree() -> void:
	#if self in Vars.forgetters:
		#Vars.forgetters.erase(self)
