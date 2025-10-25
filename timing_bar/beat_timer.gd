extends Timer


func _on_timeout() -> void:
	get_parent().on_beat_timer_timeout()
	queue_free()
