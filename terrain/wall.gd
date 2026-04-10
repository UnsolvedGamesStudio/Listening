extends StaticBody3D

@onready var area_collision: CollisionShape3D = %AreaCollision
@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D


func turn_off():
	area_collision.disabled = true
	collision_shape_3d.disabled = true
