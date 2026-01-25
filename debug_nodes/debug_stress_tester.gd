extends Node
class_name DebugStressTester

@export var enabled := false

@export_group("Global Input")
@export var blanket_debug_key := KEY_L

@export_group("Main-thread hitch")
@export var stress_main_thread_hitch := false
@export var always_active_main_thread_hitch := false
@export var main_thread_hitch_key := KEY_H
@export var main_thread_hitch_ms := 60

@export_group("Random frame jitter")
@export var stress_random_jitter := false
@export var always_active_random_jitter := false
@export var random_jitter_key := KEY_J
@export var random_jitter_chance := 0.5
@export var random_jitter_min_ms := 5
@export var random_jitter_max_ms := 50

@export_group("Restart track")
@export var stress_restart_track := false
@export var restart_track_key := KEY_R

#@export_group("Stream swap")
#@export var stress_stream_swap := false
#@export var stream_swap_key := KEY_T

var _prev_key_state := {}


func _process(_delta: float) -> void:
	if not enabled:
		return

	var blanket_pressed := (
		blanket_debug_key != KEY_NONE
		and Input.is_key_pressed(blanket_debug_key)
		)

	# ---- main-thread hitch ----
	if stress_main_thread_hitch:
		if _should_run_stressor(
			always_active_main_thread_hitch,
			main_thread_hitch_key,
			blanket_pressed
		):
			_apply_main_thread_hitch()

	# ---- random jitter ----
	if stress_random_jitter:
		if _should_run_stressor(
			always_active_random_jitter,
			random_jitter_key,
			blanket_pressed
		):
			_apply_random_jitter()

	# ---- restart track ----
	if stress_restart_track:
		if _should_run_stressor(
			false,
			restart_track_key,
			blanket_pressed,
			true
		):
			_apply_restart_track()

	# ---- stream swap ----
	#if stress_stream_swap:
		#if _should_run_stressor(
			#false,
			#stream_swap_key,
			#blanket_pressed,
			#true
		#):
			#_apply_stream_swap()

func _should_run_stressor(
	always_active: bool,
	stressor_key: int,
	blanket_pressed: bool,
	edge_triggered: bool = false
	) -> bool:
	
	if not enabled:
		return false
	
	if always_active or blanket_pressed:
		return true

	if stressor_key == KEY_NONE:
		return false

	var pressed := Input.is_key_pressed(stressor_key)
	var prev = _prev_key_state.get(stressor_key, false)

	_prev_key_state[stressor_key] = pressed

	if edge_triggered:
		return pressed and not prev

	return pressed


# Stressor implementations
func _apply_main_thread_hitch() -> void:
	if not enabled:
		return
	
	OS.delay_msec(main_thread_hitch_ms)


func _apply_random_jitter() -> void:
	if not enabled:
		return
	
	if randf() < random_jitter_chance:
		var ms := randi_range(random_jitter_min_ms, random_jitter_max_ms)
		OS.delay_msec(ms)


func _apply_restart_track() -> void:
	if not enabled:
		return
	
	if Bgm:
		Bgm.play(0.0)


#func _apply_stream_swap() -> void:
	#if Bgm:
		#Bgm.swap_to_next_debug_stream()
