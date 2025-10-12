extends Sprite2D
class_name TimingCircle

@onready var zones: Node2D = %Zones
@onready var easy_zone: Area2D = %EasyZone
@onready var medium_zone: Area2D = %MediumZone
@onready var perfect_zone: Area2D = %PerfectZone
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

const FIRE_SIGIL = preload("uid://cv18664g653gf")
const ICE_SIGIL = preload("uid://bu5poabmlsdta")
const LIGHTNING_SIGIL = preload("uid://c3brioukmdf24")

const SLOW_SPEED:= 1.0
const MEDIUM_SPEED:= 2.0
const FAST_SPEED:= 4.0

var beat_area: Area2D


func _ready() -> void:
	var easiest_zone:= perfect_zone
	
	visible_on_screen_notifier_2d.connect("screen_exited", on_screen_exited)
	Bus.beat_success_to_circle.connect(on_beat_success_to_circle)


func _process(delta: float) -> void:
	global_position.x += MEDIUM_SPEED


func remove():
	for circle in Vars.active_circles:
		if not circle == self:
			return
		
		Vars.active_circles.erase(circle)
	
	queue_free()

##Todo: Replace strings with enum/dict/other
func change_to_sigil(element: String):
	if element == "none":
		return
	
	if element == "fire":
		texture = FIRE_SIGIL
	if element == "ice":
		texture = ICE_SIGIL
	if element == "lightning":
		texture = LIGHTNING_SIGIL


func recolor(level: int):
	if level == 0:
		return
	
	if level == 1:
		modulate = Color(1.224, 0.154, 0.325)
		return
	
	if level == 2:
		modulate = Color(2.033, 0.985, 0.0)
		return
	
	if level >= 3:
		modulate = Color(0.0, 1.637, 0.0)
		return


func deactivate_zones():
	for zone: Area2D in zones.get_children():
		zone.monitorable = false
		zone.monitoring = false


func on_beat_success_to_circle(level: int, circle: TimingCircle, element: String):
	if not circle == self:
		return
	
	deactivate_zones()
	change_to_sigil(element)
	recolor(level)


func on_screen_exited():
	remove()
