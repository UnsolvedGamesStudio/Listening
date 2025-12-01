extends Node3D
class_name SpikesTile

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var hitbox: Area3D = $Hitbox
@onready var out_sfx: AudioStreamPlayer3D = %OutSFX
@onready var in_sfx: AudioStreamPlayer3D = %InSFX

var damage:= 50.0
var every_x_beat:= 3
var up:= true


func _ready() -> void:
	Bus.beat.connect(on_beat)


func on_beat(current_beat: int):
	if not current_beat % every_x_beat == 0:
		return
	
	if up == true:
		up = false
		out_sfx.play()
		animation_player.play("up_down")
		return
	
	if up == false:
		up = true
		in_sfx.play()
		animation_player.play_backwards("up_down")
		return
