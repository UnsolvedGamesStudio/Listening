@tool
extends AudioStreamPlayer3D
class_name PitchVariedPlayer

@export_range(0.01, 5.0) var pitch_range_min:= 0.9
@export_range(0.01, 5.0) var pitch_range_max:= 1.1
@export var randomize_every_time:= true

var was_set:= false


func _ready() -> void:
	finished.connect(on_finished)
	pitch_scale = randf_range(pitch_range_min, pitch_range_max)


func _process(delta: float) -> void:
	if not playing:
		return
	
	if was_set:
		return
	
	if randomize_every_time:
		pitch_scale = randf_range(pitch_range_min, pitch_range_max)
	
	print(pitch_scale)
	was_set = true


func on_finished():
	was_set = false
