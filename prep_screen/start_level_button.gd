extends PanelContainer


func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("cast"):
		on_clicked()


func on_clicked():
	Filters.fade.play("fade_out")
	await Filters.fade.animation_finished
	SceneManager.switch_scene("layout")


func on_mouse_entered():
	get_theme_stylebox("panel").border_width_left = 0
	get_theme_stylebox("panel").border_width_bottom = 0


func on_mouse_exited():
	get_theme_stylebox("panel").border_width_left = 2
	get_theme_stylebox("panel").border_width_bottom = 2
