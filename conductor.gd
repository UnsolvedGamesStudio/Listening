extends AudioStreamPlayer


@export var bpm:= 120.0
@export var measures:= 4
@export var slow:= false
@export var off:= false



func _ready() -> void:
	if slow == true:
		bpm *= 0.5
	BeatVars.seconds_per_beat = 60.0 / bpm


func _physics_process(_delta: float):
	if off == true:
		if playing:
			stop()
		
		return
	
	BeatVars.frames_since_last_beat += 1
	## Loop
	if not playing:
		play()
		BeatVars.last_reported_beat = -1
		return
	
	BeatVars.song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
	BeatVars.song_position -= AudioServer.get_output_latency()
	BeatVars.song_position_in_beats = int( floor(BeatVars.song_position / BeatVars.seconds_per_beat) + BeatVars.beats_before_start )
	_report_beat()
	#print(BeatVars.frames_since_last_beat)
	#prints("song_position: ", song_position, ". song_position_in_beats: ", song_position_in_beats, ". last_reported_beat: ", last_reported_beat)


func _report_beat():
	if BeatVars.last_reported_beat < BeatVars.song_position_in_beats:
		if BeatVars.current_measure > measures:
			Bus.measure_played.emit()
			BeatVars.current_measure = 1
		
		Bus.beat_played.emit()
		BeatVars.frames_since_last_beat = 0
		BeatVars.last_reported_beat = BeatVars.song_position_in_beats
		BeatVars.current_measure += 1
