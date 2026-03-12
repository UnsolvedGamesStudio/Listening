extends CanvasLayer

@onready var noise_fade: AnimationPlayer = %NoiseFade
@onready var noise_shift: AnimationPlayer = %NoiseShift
@onready var fade: AnimationPlayer = %Fade
@onready var fade_black: AnimationPlayer = %FadeBlack
@onready var pause_shader_fade: AnimationPlayer = %PauseShaderFade


func _process(delta: float) -> void:
	if not fade.current_animation == "fade_in":
		return
	
	var pos:= fade.current_animation_position
	var length:= fade.current_animation_length
	
	if pos > length * 0.55:
		Vars.can_move_camera = true


func fade_out():
	fade.play("fade_out")
	await fade.animation_finished
	Bus.fade_out_ended.emit()


func fade_in():
	fade.play("fade_in")
	Vars.can_move_camera = false
	await fade.animation_finished
	Bus.fade_in_ended.emit()
