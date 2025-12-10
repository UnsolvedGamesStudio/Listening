extends Button


func _ready() -> void:
	button_up.connect(on_button_up)
	mouse_entered.connect(on_mouse_entered)
	button_down.connect(on_button_down)


func close():
	owner.queue_free()
	Find.P().can_interact = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		close()


func on_mouse_entered():
	GlobalSfx.ui_hover.play()


func on_button_down():
	GlobalSfx.ui_click.play()


func on_button_up():
	close()
