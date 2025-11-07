extends EnemyBehavior
class_name RotateToPlayerEB

@export var to_rotate: Node3D
var valid:= true


func enter() -> void:
	if to_rotate == null:
		printerr(self, " of ", owner, ": to_rotate not found")
		valid = false


func _physics_process(delta: float) -> void:
	if valid == false:
		return
	
	to_rotate.look_at(find_player().global_position)
