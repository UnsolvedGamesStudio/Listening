extends Node3D

@onready var broken: Node3D = %Broken
@onready var unbroken: Node3D = %Unbroken
@onready var break_sfx: AudioStreamPlayer3D = %BreakSFX


func on_break():
	broken.show()
	unbroken.hide()
	break_sfx.pitch_scale *= randf_range(0.8, 1.2)
	break_sfx.play()
