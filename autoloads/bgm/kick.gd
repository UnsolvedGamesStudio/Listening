extends AudioStreamPlayer


func _ready() -> void:
	Bus.beat.connect(on_beat)


func on_beat(beat_count: int):
	if playing:
		stop()
	
	play()
