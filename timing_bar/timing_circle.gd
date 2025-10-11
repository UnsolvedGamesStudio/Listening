extends Sprite2D
class_name timing_circle

const RANK_LABEL = preload("uid://6w4l5x6wfeyn")

@onready var medium_zone: Area2D = %MediumZone
@onready var kill: AnimationPlayer = %Kill

var kill_point:= 0.0
var direction:= 1.0


func _physics_process(delta: float) -> void:
	global_position.x += 1 * direction
	
	if global_position.x == kill_point:
		kill.play("kill")


func generate_text():
	var text_inst:= RANK_LABEL.instantiate()
	
	get_parent().add_child(text_inst)


func remove():
	for circle in Vars.active_circles:
		if not circle == self:
			return
		
		Vars.active_circles.erase(circle)
	
	queue_free()
