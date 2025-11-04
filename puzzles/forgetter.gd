extends Node3D
class_name Forgetter
##Todo: add export to the tilemap letting you pick how many synapses are\
## required for which number of forgetter
@onready var area_3d: Area3D = %Area3D
@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D

var puzzle_id:= -1
var active:= true
var forgotten_nodes: Array[Node3D] = []
var remembered_nodes: Array[Node3D] = []


func _ready() -> void:
	Vars.forgetters.append(self)
	set_collision_size()
	area_3d.area_entered.connect(on_area_3d_area_entered)
	await get_tree().create_timer(0.25).timeout
	active = false


func set_collision_size():
	collision_shape_3d.shape.size.x = Vars.cell_size - 0.01
	collision_shape_3d.shape.size.z = Vars.cell_size - 0.01


func forget_cell(area: Area3D):
	var cell = area.owner
	if not cell.owner.owner is WalledCell:
		return
	
	forget(cell.owner.owner)


func forget_entity(area: Area3D):
	if not area.owner is Node3D:
		return
	
	forget(area.owner)


func forget(object: Node3D):
	object.hide()
	object.process_mode = Node.PROCESS_MODE_DISABLED
	forgotten_nodes.append(object)


func remember():
	for object: Node3D in forgotten_nodes:
		object.show()
		object.process_mode = Node.PROCESS_MODE_INHERIT
		remembered_nodes.append(object)
	forgotten_nodes.clear()


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
