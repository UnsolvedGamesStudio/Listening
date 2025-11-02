extends Node3D
class_name EnemyIndicator

@onready var ground_raycast: RayCast3D = %GroundRaycast
@onready var mesh_instance_3d: MeshInstance3D = %MeshInstance3D

@export var gray:= false


func _ready() -> void:
	if gray == false:
		return
	
	mesh_instance_3d.get_active_material(0).albedo_color = Color.WHITE


func _process(delta: float) -> void:
	if not ground_raycast.is_colliding():
		return
	
	if not is_instance_valid(ground_raycast.get_collider()):
		return
	
	global_position.y = ground_raycast.get_collider().global_position.y + 0.6
