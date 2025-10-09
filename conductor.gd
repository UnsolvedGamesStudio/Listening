extends AudioStreamPlayer


@export var bpm:= 120.0
@export var measures:= 4
@export var slow:= false
@export var off:= false

var song_position:= 0.0
var song_position_in_beats:= 1
var seconds_per_beat:= 60.0 / bpm
var last_reported_beat:= -1
var beats_before_start:= 0
var current_measure:= 1

var closest:= 0


func _ready() -> void:
	if slow == true:
		bpm *= 0.5
	seconds_per_beat = 60.0 / bpm


func _physics_process(_delta: float):
	if off == true:
		if playing:
			stop()
		
		return
	
	## Loop
	if not playing:
		play()
		last_reported_beat = -1
		return
	
	song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
	song_position -= AudioServer.get_output_latency()
	song_position_in_beats = int( floor(song_position / seconds_per_beat) + beats_before_start )
	_report_beat()
	
	#prints("song_position: ", song_position, ". song_position_in_beats: ", song_position_in_beats, ". last_reported_beat: ", last_reported_beat)


func _report_beat():
	if last_reported_beat < song_position_in_beats:
		if current_measure > measures:
			Bus.measure_played.emit()
			current_measure = 1
		
		Bus.beat_played.emit()
		last_reported_beat = song_position_in_beats
		current_measure += 1
