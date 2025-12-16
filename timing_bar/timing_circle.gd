extends Sprite2D
class_name TimingCircle
## Todo: Make offset instantly nudge existing circles
@onready var zones: Node2D = %Zones
@onready var easy_zone: Area2D = %EasyZone
@onready var medium_zone: Area2D = %MediumZone
@onready var perfect_zone: Area2D = %PerfectZone
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var speed:= 8 ## 1 = highest. value is rounded up to the next even number.
var beat_area: Area2D
var touched_middle:= false
var original_texture: Texture

var start_pos:= Vector2.ZERO
var middle_pos:= Vector2.ZERO
var end_pos:= Vector2.ZERO

var travel_to_middle_duration:= 2.2
var post_middle_duration:= 2.2
var spawn_time:= 0.0

var beats_ahead = ceil(travel_to_middle_duration / Bgm.rhythm_notifier.beat_length)


func _ready() -> void:
	var easiest_zone := perfect_zone
	
	# remove this line — the spawner will set spawn_time:
	# spawn_time = Bgm.rhythm_notifier.current_position - travel_to_middle_duration
	
	original_texture = texture
	visible_on_screen_notifier_2d.connect("screen_exited", on_screen_exited)
	Bus.beat_success_to_circle.connect(on_beat_success_to_circle)
	Bus.beat.connect(on_beat)
	
	easiest_zone.area_entered.connect(on_easiest_zone_area_entered)
	easiest_zone.area_exited.connect(on_easiest_zone_area_exited)


func setup_for_beat(target_beat_time: float) -> void:
	# target_beat_time = the time (in seconds) that this circle MUST be at middle_pos
	# compute spawn_time so it starts travelling early enough
	spawn_time = target_beat_time - travel_to_middle_duration + (Vars.beat_circle_offset / 1000)
	
	# set immediate visual to the start position so the circle appears at your start location
	# (set position, not global_position; the BeatVisualizer will add_child first)
	position = start_pos
	
	update_visual_to_now()
	
	# optional: if your node runs _ready and sets spawn_time too early, avoid that by checking
	# we override anything set earlier. _ready should not set spawn_time unconditionally anymore.


func update_visual_to_now() -> void:
	var now: float = Bgm.rhythm_notifier.current_position
	# if not started yet, stay at start_pos
	if now < spawn_time:
		position = start_pos
		return

	var t := (now - spawn_time) / travel_to_middle_duration
	t = clamp(t, 0.0, 1.0)
	if t < 1.0:
		position = start_pos.lerp(middle_pos, t)
		return

	# after middle
	var t2 := (now - spawn_time - travel_to_middle_duration) / post_middle_duration
	t2 = clamp(t2, 0.0, 1.0)
	position = middle_pos.lerp(end_pos, t2)


func _process(delta: float) -> void:
	var now: float = Bgm.rhythm_notifier.current_position
	var t = (now - spawn_time) / travel_to_middle_duration
	
	if now < spawn_time:
		return  # not yet started
	
	t = clamp(t, 0.0, 1.0)
	
	if t < 1.0:
		# traveling towards the middle
		position = start_pos.lerp(middle_pos, t)
	else:
		# traveling past the middle
		var t2 = (now - spawn_time - travel_to_middle_duration) / post_middle_duration
		t2 = clamp(t2, 0.0, 1.0)
		position = middle_pos.lerp(end_pos, t2)
		
		if t2 >= 1.0:
			queue_free()


#func tween_position():
	#if speed % 2 == 1:
		#speed += 1
	#
	#var tween:= create_tween()
	#var length: float = Bgm.rhythm_notifier.beat_length * speed
	#
	#tween.tween_property(self, "global_position:x", get_viewport_rect().size.x, length)
	#tween.tween_callback(remove)


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


func change_texure(new_texture: Texture):
	if not texture == original_texture:
		return
	
	texture = new_texture


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
	touched_middle = true
	
	if area.owner is BeatVisualizer and Bgm.circles_are_in == false:
		Bgm.circles_are_in = true
	
	Vars.in_timing_window = true


func on_easiest_zone_area_exited(area: Area2D):
	Vars.in_timing_window = false


func on_beat(beat_count: int):
	if beat_count % 2 == 0:
		scale = Vector2(1.1, 1.1)
	
	if beat_count % 2 == 1:
		scale = Vector2(1.0, 1.0)


func on_screen_exited():
	remove()
