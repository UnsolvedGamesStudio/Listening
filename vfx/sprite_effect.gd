extends Sprite3D

@onready var kill_timer: Timer = %KillTimer

var lifetime:= 0.2


func _ready() -> void:
	kill_timer.timeout.connect(on_kill_timer_timeout)
	kill_timer.start(lifetime)


func on_kill_timer_timeout():
	queue_free()
