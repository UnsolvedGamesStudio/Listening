extends Sprite3D

@export var animate:= false


func _ready() -> void:
	Bus.beat.connect(on_beat)
	frame = randi_range(0, 1)


func on_beat(beat_count):
	if animate == false:
		return
	
	if hframes < 2:
		return
	
	if frame == 0:
		frame = 1
	elif frame == 1:
		frame = 0
