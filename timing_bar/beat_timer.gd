extends Timer


func _ready() -> void:
	timeout.connect(on_timeout)


func on_timeout() -> void:
	get_parent().on_beat_timer_timeout()
	queue_free()
