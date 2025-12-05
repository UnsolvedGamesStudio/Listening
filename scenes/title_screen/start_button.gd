extends Button

@onready var title_appear: AnimationPlayer = %TitleAppear

var small_brain: Node3D
var spin_anim: AnimationPlayer
var starting_anim_speed:= 1.0
var starting_small_brain_height:= 1.0
var mouse_in:= false


func _ready() -> void:
	small_brain = get_tree().get_first_node_in_group("small_brain")
	spin_anim = get_tree().get_first_node_in_group("spin_anim")
	starting_anim_speed = spin_anim.speed_scale
	starting_small_brain_height = small_brain.scale.y
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)


func _process(delta: float) -> void:
	if scale.x < 0.1:
		return
	
	if mouse_in == true:
		increase()
	
	else:
		turn_back()


func increase():
	scale += (Vector2.ONE / randf_range(50, 500))
	Bgm.non_beat_bgm.pitch_scale += 0.0005
	
	if not spin_anim == null:
		spin_anim.speed_scale += 0.005
	
	var stretch_rate:= 0.0002
	stretch_rate *= 1.0075
	
	var brain_stretch_rate:= 0.00005
	brain_stretch_rate *= 1.133
	
	if not small_brain == null:
		small_brain.scale.y += (brain_stretch_rate)
	
	get_parent().get_parent().scale.y += stretch_rate


func turn_back():
	scale = Vector2.ONE
	Bgm.non_beat_bgm.pitch_scale = 1.0
	
	if not spin_anim == null:
		spin_anim.speed_scale = starting_anim_speed
	
	if not small_brain == null:
		small_brain.scale.y = starting_small_brain_height
	
	get_parent().get_parent().scale.y = 1.0


func _gui_input(event: InputEvent) -> void:
	var main: MainScene = get_tree().get_first_node_in_group("main_scene")
	
	if not event.is_action_pressed("cast"):
		return
	
	start()


func start():
	GlobalSfx.ui_click.play()
	title_appear.play_backwards("appear")
	Filters.fade.play("fade_out")
	GlobalSfx.rewind.play()
	await Filters.fade.animation_finished
	Bgm.non_beat_bgm.stop()
	Filters.fade.play("fade_out")
	Bgm.non_beat_bgm.pitch_scale = 1.0
	
	SceneManager.switch_scene(SceneManager.scenes.HUB_WORLD)


func on_mouse_entered():
	GlobalSfx.ui_hover.play()
	mouse_in = true


func on_mouse_exited():
	mouse_in = false
