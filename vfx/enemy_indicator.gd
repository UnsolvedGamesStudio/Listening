extends Node3D
class_name EnemyIndicator

@onready var ray_cast_3d: RayCast3D = %RayCast3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

@export var color:= Color.RED


func _process(delta: float) -> void:
	if not ray_cast_3d.is_colliding():
		return
	
	if not is_instance_valid(ray_cast_3d.get_collider()):
		return
	
	global_position.y = ray_cast_3d.get_collider().global_position.y + 0.6
