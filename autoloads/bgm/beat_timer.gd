extends Node
class_name BeatTimer

## Fired once per true musical beat
signal beat(beat_tick: int, is_catch_up: bool)

## Fired once per subdivision tick (e.g. 32x per beat)
signal sub_tick(sub_tick: int, is_catch_up: bool)

const SUBDIVISIONS: int = 32

@export var audio_player: AudioStreamPlayer ## Connected player
@export var bpm: float = 120.0 ## Song's BPM
@export var print_accuracy:= false ## Prints a benchmark

# ---- Public state ----
var audio_pos: float = 0.0 ## Continuous playback time, corrected for latency and looping
var beat_length: float = 0.0
var sub_length: float = 0.0

var current_beat_tick: int = -1
var current_sub_tick: int = -1

# ---- Internal ----
var _last_emitted_sub_tick: int = -1
var _last_stream: AudioStream

# ---- Accuracy diagnostics (true beats only) ----
var _last_accuracy_beat:= -1
var _max_error_ms:= 0.0
var _avg_error_ms:= 0.0
var _sample_count:= 0
var _prev_raw_playback_pos:= 0.0
var _loop_count:= 0


func _process(_delta: float) -> void:
	if not audio_player.playing:
		return
	
	var stream_changed:= audio_player.stream != _last_stream ## If the previously set stream is not the current one
	## If the audio stream resource changed, reset timing
	if stream_changed:
		_last_stream = audio_player.stream
		reset_playback_timing()
		return
	
	## Get the exact position in the song
	_update_audio_pos()
	## Update the length variables dynamically
	_update_lengths()
	
	var target_sub_tick:= int( floor(audio_pos / sub_length) ) ## Which beat subdivision the song is on
	var is_catch_up:= false ## Whether the subdivision was skipped over due to frame timing
	
	## Check whether the current subdivision went up by more than 1 compared to previous
	if _last_emitted_sub_tick + 1 < target_sub_tick:
		is_catch_up = true
	
	## For every new subdivision since last frame:
	while _last_emitted_sub_tick < target_sub_tick:
		## Store previous subdivision index
		_last_emitted_sub_tick += 1
		## Update current_sub_tick and emit beat and sub_tick signals
		_on_sub_tick(_last_emitted_sub_tick, is_catch_up)


func _update_audio_pos() -> void:
	var raw_pos:= (
		audio_player.get_playback_position() ## Get the current song time
		+ AudioServer.get_time_since_last_mix() ## Add the time audio was last mixed, which can happen between frames
		- AudioServer.get_output_latency() ## Remove the time it takes for sound to output
	) ## Accurate song position
	
	## If real position is less than the previous frame's, it means the song probably looped
	if raw_pos < _prev_raw_playback_pos - 0.01:
		_loop_count += 1
	
	## Store previous position
	_prev_raw_playback_pos = raw_pos
	
	## Set the true time, by adding previous loops' length to current position
	audio_pos = raw_pos + ( _loop_count * audio_player.stream.get_length() )


func _update_lengths() -> void:
	beat_length = 60.0 / bpm ## 60 seconds in a minute
	sub_length = beat_length / SUBDIVISIONS


func _on_sub_tick(target_sub_tick: int, is_catch_up: bool) -> void:
	current_sub_tick = target_sub_tick
	## Emit the sub_tick signal, with which subdivision has been reached, and whether it\
	## happened during catch up
	sub_tick.emit(target_sub_tick, is_catch_up)
	
	## If the subdivision threshold is reached:
	if target_sub_tick % SUBDIVISIONS == 0:
		@warning_ignore("integer_division")
		var beat_index:= target_sub_tick / SUBDIVISIONS ## Total subdivision thresholds reached
		current_beat_tick = beat_index
		## Emit the beat signal, with which beat has been reached, and whether it happened\
		## during catch up
		beat.emit(beat_index, is_catch_up)
		## If print_accuracy enabled: tries to detect accuracy
		_measure_beat_accuracy(beat_index)

## Restart beat progress
func reset_playback_timing():
	_last_emitted_sub_tick = -1
	current_sub_tick = -1
	current_beat_tick = -1
	_loop_count = 0
	_prev_raw_playback_pos = 0.0
	audio_pos = 0.0


# -------------------------------------------------
# Accuracy diagnostics (true beats only)
# -------------------------------------------------
func _measure_beat_accuracy(beat_index: int) -> void:
	if print_accuracy == false:
		return
	
	if beat_index == _last_accuracy_beat:
		return
	
	_last_accuracy_beat = beat_index
	
	var expected_time:= beat_index * beat_length
	var error_sec:= audio_pos - expected_time
	var error_ms:= error_sec * 1000.0
	
	_sample_count += 1
	_avg_error_ms += (error_ms - _avg_error_ms) / _sample_count
	_max_error_ms = max(_max_error_ms, abs(error_ms))
	
	print(
		"[BEAT ACCURACY]",
		"beat=", beat_index,
		"error_ms=", snapped(error_ms, 0.01),
		"avg_ms=", snapped(_avg_error_ms, 0.01),
		"max_ms=", snapped(_max_error_ms, 0.01)
	)
