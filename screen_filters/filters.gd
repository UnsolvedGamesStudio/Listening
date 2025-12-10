extends CanvasLayer

@onready var noise_fade: AnimationPlayer = %NoiseFade
@onready var noise_shift: AnimationPlayer = %NoiseShift
@onready var fade: AnimationPlayer = %Fade
@onready var fade_black: AnimationPlayer = %FadeBlack
@onready var pause_shader_fade: AnimationPlayer = %PauseShaderFade


func fade_out():
	fade.play("fade_out")
	await fade.animation_finished
	Bus.fade_out_ended.emit()


func fade_in():
	fade.play("fade_in")
	await fade.animation_finished
	Bus.fade_in_ended.emit()
