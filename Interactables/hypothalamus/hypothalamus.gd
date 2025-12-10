extends Obstacle

@onready var parts: Node3D = %Parts
@onready var screen: Node3D = %Screen


func _physics_process(delta: float) -> void:
	disable_when_far()


func disable_when_far():
	var player:= Find.P()
	var object_pos: Vector3 = global_position
	var is_close:= object_pos.distance_to(Find.P().global_position) < 10.0
	var is_screen_on_screen:= player.camera.is_position_in_frustum(screen.global_transform.origin)
	
	if is_close or is_screen_on_screen:
		if parts.process_mode == Node.PROCESS_MODE_INHERIT:
			return
		
		parts.process_mode = Node.PROCESS_MODE_INHERIT
	
	else:
		if parts.process_mode == Node.PROCESS_MODE_DISABLED:
			return
		
		parts.process_mode = Node.PROCESS_MODE_DISABLED
