extends AudioStreamPlayer


func _ready() -> void:
	Bus.circle_spawned.connect(on_circle_spawned)


func on_circle_spawned():
	if playing:
		stop()
	
	play()
