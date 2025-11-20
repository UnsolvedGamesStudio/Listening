extends Button

@onready var title_appear: AnimationPlayer = %TitleAppear

var mouse_in:= false


func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)


func _process(delta: float) -> void:
	if scale.x < 0.1:
		return
	
	if mouse_in == true:
		scale += (Vector2.ONE / randf_range(50, 500))
	else:
		scale = Vector2.ONE


func _gui_input(event: InputEvent) -> void:
	var main: MainScene = get_tree().get_first_node_in_group("main_scene")
	
	if not event.is_action_pressed("cast"):
		return
	
	start()


func start():
	title_appear.play_backwards("appear")
	Filters.fade.play("fade_out")
	await Filters.fade.animation_finished
	Bgm.non_beat_bgm.stop()
	Filters.fade.play("fade_out")
	
	SceneManager.switch_scene("hub_world")


func on_mouse_entered():
	mouse_in = true


func on_mouse_exited():
	mouse_in = false
