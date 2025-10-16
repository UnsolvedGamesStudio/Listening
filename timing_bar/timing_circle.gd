extends Sprite2D
class_name TimingCircle

@onready var zones: Node2D = %Zones
@onready var easy_zone: Area2D = %EasyZone
@onready var medium_zone: Area2D = %MediumZone
@onready var perfect_zone: Area2D = %PerfectZone
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

@export_range(1, 2) var speed_level:= 2

var speed:= 2.0
var beat_area: Area2D


func _ready() -> void:
	var easiest_zone:= perfect_zone
	
	visible_on_screen_notifier_2d.connect("screen_exited", on_screen_exited)
	Bus.beat_success_to_circle.connect(on_beat_success_to_circle)
	easiest_zone.area_exited.connect(on_easiest_zone_area_exited)
	
	if speed_level == 1:
		speed = 1.0
	if speed_level == 2:
		speed = 2.0


func _process(delta: float) -> void:
	global_position.x += speed_level


func remove():
	for circle in Vars.active_circles:
		if not circle == self:
			return
		
		Vars.active_circles.erase(circle)
	
	queue_free()


func change_speed(amount: int):
	speed_level = min(amount, 2)
	
	if speed_level == 1:
		speed = 1.0
	if speed_level == 2:
		speed = 2.0


#func change_to_sigil(element: int):
	#if element == -1:
		#return
	#
	#if not "texture" in Vars.elements[element]:
		#return
	#
	#texture = Vars.elements[element].texture


func recolor(level: int):
	if level == 0:
		return
	
	if level == 1:
		material.set_shader_parameter("clr", Color(0.736, 0.68, 0.284, 1.0))
		return
	
	if level == 2:
		material.set_shader_parameter("clr", Color(0.588, 0.627, 0.03, 1.0))
		return
	
	if level >= 3:
		material.set_shader_parameter("clr", Color(0.0, 0.595, 0.337, 1.0))
		return


func deactivate_zones():
	for zone: Area2D in zones.get_children():
		zone.monitorable = false
		zone.monitoring = false


func on_beat_success_to_circle(level: int, circle: TimingCircle, element: int):
	if not circle == self:
		return
	
	deactivate_zones()
	#change_to_sigil(element)
	recolor(level)


func on_easiest_zone_area_exited(area: Area2D):
	material.set_shader_parameter("clr", Color(0.68, 0.053, 0.223, 1.0))


func on_screen_exited():
	remove()
