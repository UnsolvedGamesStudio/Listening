extends EnemyBehavior
class_name AnimToTheBeatEB

@export_group("Animation Player")
@export var anim_enabled:= true
@export var anim_player: AnimationPlayer
@export var anim_every_x_beat:= 2
@export var anim_sequence: Array[String] = ["animation1", "animation2"]

@export_group("Audio")
@export var audio_enabled:= true
@export var audio_player: AudioStreamPlayer3D
@export var audio_every_x_beat:= 2
@export_subgroup("Pitch")
@export var vary_pitch:= true
@export_range(0.01, 5.0) var min_pitch:= 0.9
@export_range(0.01, 5.0) var max_pitch:= 1.1

@export_group("Random Delay")
@export var randomize_timing:= false
@export_range(0.0, 5.0) var min_delay:= 0.0
@export_range(0.01, 10.0) var max_delay:= 0.15

var delay_timer: Timer
var anim_progress:= 0


func _ready() -> void:
	Bus.beat.connect(on_beat)
	
	if randomize_timing == true:
		delay_timer = Timer.new()
		add_child(delay_timer)
		delay_timer.wait_time = randf_range(min_delay, max_delay)
		delay_timer.one_shot = true


func animate_sprite():
	if anim_enabled == false:
		return
	
	if anim_player == null:
		push_error(self, " of ", O, ": AnimationPlayer not found")
		return
	
	var anim_amount:= anim_sequence.size()
	var correct_anim:= anim_sequence[anim_progress]
	
	if not correct_anim in anim_player.get_animation_list():
		push_error(self, ": Anim player does not have '", correct_anim, "'")
		return
	
	await delay()
	
	anim_player.stop()
	anim_player.play(correct_anim)
	
	anim_progress += 1
	
	if anim_progress == anim_amount:
		anim_progress = 0


func animate_audio():
	if O.sees_player == false:
		return
	
	if audio_enabled == false:
		return
	
	if audio_player == null:
		push_error(self, " of ", O, ": AudioStream not found")
		return
	
	if vary_pitch:
		var og_pitch:= audio_player.pitch_scale
		
		audio_player.pitch_scale += randf_range(min_pitch, max_pitch)
		audio_player.pitch_scale = og_pitch
	
	await delay()
	
	audio_player.play()


func delay():
	if not delay_timer:
		return
	
	delay_timer.start()
	await delay_timer.timeout


func on_beat(beat_count: int):
	if enabled == false:
		return
	
	var anim_speed:= anim_every_x_beat
	var audio_speed:= audio_every_x_beat
	
	if anim_every_x_beat == 0:
		anim_speed = 99999
	
	if audio_every_x_beat == 0:
		audio_speed = 99999
	
	var correct_anim_beat:= beat_count % anim_speed == 0
	var correct_audio_beat:= beat_count % audio_speed == 0
	
	if correct_anim_beat:
		animate_sprite()
	
	if correct_audio_beat:
		animate_audio()
