extends Node3D

var rotations:= [-180.0, -90.0, 0.0, 90.0]


func _ready() -> void:
	global_rotation_degrees.y = rotations.pick_random()
