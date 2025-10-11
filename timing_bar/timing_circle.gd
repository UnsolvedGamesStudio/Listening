extends Sprite2D
class_name timing_circle

@onready var zones: Node2D = %Zones
@onready var easy_zone: Area2D = %EasyZone
@onready var medium_zone: Area2D = %MediumZone
@onready var perfect_zone: Area2D = %PerfectZone
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

const SLOW_SPEED:= 1.0
const MEDIUM_SPEED:= 2.0
const FAST_SPEED:= 4.0

var beat_area: Area2D


func _ready() -> void:
	var easiest_zone:= perfect_zone
	
	visible_on_screen_notifier_2d.connect("screen_exited", on_screen_exited)


func _process(delta: float) -> void:
	global_position.x += MEDIUM_SPEED


func remove():
	for circle in Vars.active_circles:
		if not circle == self:
			return
		
		Vars.active_circles.erase(circle)
	
	queue_free()


func on_screen_exited():
	remove()
