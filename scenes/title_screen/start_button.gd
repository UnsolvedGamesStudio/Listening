extends Button

var mouse_in:= false


func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	


func _process(delta: float) -> void:
	if mouse_in == true:
		scale += (Vector2.ONE / randf_range(50, 500))
	else:
		scale = Vector2.ONE


func _gui_input(event: InputEvent) -> void:
	if not event.is_action_pressed("cast"):
		return
	
	var scene_manager: SceneManager = get_tree().get_first_node_in_group("main_scene")
	Bgm.non_beat_bgm.stop()
	scene_manager.switch_scene("layout")


func on_mouse_entered():
	mouse_in = true


func on_mouse_exited():
	mouse_in = false
