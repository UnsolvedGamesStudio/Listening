extends Sprite2D
class_name TimingCircle

@onready var zones: Node2D = %Zones
@onready var easy_zone: Area2D = %EasyZone
@onready var medium_zone: Area2D = %MediumZone
@onready var perfect_zone: Area2D = %PerfectZone
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var speed:= 8 ##1 = highest. value is rounded up to the next even number.
var beat_area: Area2D


func _ready() -> void:
	var easiest_zone:= perfect_zone
	
	visible_on_screen_notifier_2d.connect("screen_exited", on_screen_exited)
	Bus.beat_success_to_circle.connect(on_beat_success_to_circle)
	easiest_zone.area_entered.connect(on_easiest_zone_area_entered)
	easiest_zone.area_exited.connect(on_easiest_zone_area_exited)
	
	tween_position()


func tween_position():
	if speed % 2 == 1:
		speed += 1
	
	var tween:= create_tween()
	var length: float = Bgm.rhythm_notifier.beat_length * speed
	
	tween.tween_property(self, "global_position:x", get_viewport_rect().size.x, length)
	tween.tween_callback(remove)


func remove():
	animation_player.play("exit")
	
	for circle in Vars.active_circles:
		if circle == self:
			Vars.active_circles.erase(circle)


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
	recolor(level)


func on_easiest_zone_area_entered(area: Area2D):
	if area.owner is BeatVisualizer and Bgm.circles_are_in == false:
		Bgm.circles_are_in = true


func on_easiest_zone_area_exited(area: Area2D):
	material.set_shader_parameter("clr", Color(0.68, 0.053, 0.223, 1.0))


func on_screen_exited():
	remove()
