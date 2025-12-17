extends Node
class_name CircleBeatTimer

## Fired once per true musical beat
signal circle_beat()

@export var audio_player: AudioStreamPlayer
@export var bpm: float = 120.0
@export var subdivisions: int = 32
@export var print_accuracy:= false

# ---- Public state ----
var audio_pos: float = 0.0
var beat_length: float = 0.0            # seconds per true beat
var sub_length: float = 0.0             # seconds per subdivision

var current_beat: int = -1
var current_sub: int = -1

# ---- Internal ----
var _last_sub_index: int = -1

# ---- Accuracy diagnostics (true beats only) ----
var _last_accuracy_beat := -1
var _max_error_ms := 0.0
var _avg_error_ms := 0.0
var _sample_count := 0


func _process(_delta: float) -> void:
	if not audio_player.playing:
		return

	_update_audio_time()
	_update_lengths()

	var sub_index := int(floor(audio_pos / sub_length))

	# Catch up safely under stutter
	while _last_sub_index < sub_index:
		_last_sub_index += 1
		_on_sub_tick(_last_sub_index)


func _update_audio_time() -> void:
	# High-precision audio clock
	audio_pos = (
		audio_player.get_playback_position()
		+ AudioServer.get_time_since_last_mix()
		- AudioServer.get_output_latency()
	)


func _update_lengths() -> void:
	beat_length = 60.0 / bpm
	sub_length = beat_length / subdivisions


func _on_sub_tick(sub_index: int) -> void:
	current_sub = sub_index

	# True beat boundary
	if sub_index % subdivisions == 0:
		@warning_ignore("integer_division")
		var beat_index := sub_index / subdivisions
		current_beat = beat_index
		circle_beat.emit(beat_index)
		_measure_beat_accuracy(beat_index)


# -------------------------------------------------
# Accuracy diagnostics (true beats only)
# -------------------------------------------------
func _measure_beat_accuracy(beat_index: int) -> void:
	if print_accuracy == false:
		return
	
	if beat_index == _last_accuracy_beat:
		return

	_last_accuracy_beat = beat_index

	var expected_time := beat_index * beat_length
	var error_sec := audio_pos - expected_time
	var error_ms := error_sec * 1000.0

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
