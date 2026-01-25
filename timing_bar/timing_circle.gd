extends Sprite2D
class_name TimingCircle
## Todo: Make offset instantly nudge existing circles
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var speed:= 8 ## 1 = highest. value is rounded up to the next even number.
var beat_area: Area2D
var touched_middle:= false
var original_texture: Texture

var start_pos:= Vector2.ZERO
var middle_pos:= Vector2.ZERO
var end_pos:= Vector2.ZERO

var travel_to_middle_duration:= 2.4
var post_middle_duration:= 2.4
var spawn_time:= 0.0


func _ready() -> void:
	original_texture = texture
	
	Bus.beat_success_to_circle.connect(on_beat_success_to_circle)
	Bus.beat.connect(on_beat)


func setup_for_beat(target_beat_time: float) -> void:
	spawn_time = target_beat_time - travel_to_middle_duration + (Vars.beat_circle_offset / 1000.0)


func _physics_process(delta: float) -> void:
	var now: float = Bgm.beat_timer.audio_pos
	var t = (now - spawn_time) / travel_to_middle_duration
	
	if now < spawn_time:
		return
	
	t = clamp(t, 0.0, 1.0)
	
	if t < 1.0:
		position = start_pos.lerp(middle_pos, t)
	else:
		var t2 = (now - spawn_time - travel_to_middle_duration) / post_middle_duration
		t2 = clamp(t2, 0.0, 1.0)
		position = middle_pos.lerp(end_pos, t2)
		
		if t2 >= 1.0:
			remove()


func remove():
	
	queue_free()
	animation_player.play("exit")


func recolor(level: int):
	if level == 0:
		return
	
	if level == 1:
		material.set_shader_parameter("clr", Color(0.827, 0.592, 0.255, 1.0))
		return
	
	if level == 2:
		material.set_shader_parameter("clr", Color(0.678, 0.722, 0.204, 1.0))
		return
	
	if level >= 3:
		material.set_shader_parameter("clr", Color(0.259, 0.643, 0.349, 1.0))
		return


func change_texure(new_texture: Texture):
	if not texture == original_texture:
		return
	
	texture = new_texture


func on_beat_success_to_circle(level: int, circle: TimingCircle, element: int):
	if not circle == self:
		return
	
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


func _exit_tree() -> void:
	if Bus.beat_success_to_circle.is_connected(on_beat_success_to_circle):
		Bus.beat_success_to_circle.disconnect(on_beat_success_to_circle)
	
	if Bus.beat.is_connected(on_beat):
		Bus.beat.disconnect(on_beat)
