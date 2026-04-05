extends PanelContainer


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("comboless_cast"):
		modulate = Color(1.0, 0.549, 0.752, 0.643)
	else:
		modulate = Color(1.0, 1.0, 1.0, 1.0)
