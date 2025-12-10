extends CanvasLayer

@onready var loading_circle: TextureRect = %LoadingCircle
@onready var label: Label = %Label

var completion: float = 0.0

var previous_value:= 0.0
var target_add:= 0.0

var finished:= false


func _ready() -> void:
	completion = loading_circle.material.get_shader_parameter("progress")
	SceneManager.loading_thread_started.connect(on_loading_started)
	var mat:= loading_circle.material


func _process(delta: float) -> void:
	if finished == true:
		return
	
	var target:= 0.0
	
	if SceneManager.loading_in_progress == true:
		target = SceneManager.current_loading_progress + target_add
	else:
		target = 1.0
	
	completion = move_toward(completion, target, delta * 2)
	loading_circle.material.set_shader_parameter("progress", completion)
	label.text = str(completion * 100.0 as int)
	
	if completion == previous_value:
		target_add += 0.01
	
	previous_value = completion
	
	if completion >= 1.0 and SceneManager.current_loading_progress >= 1.0:
		finished = true
		await get_tree().create_timer(0.1).timeout
		Bus.loading_screen_finished.emit()
		hide()


func on_loading_started(scene):
	if SceneManager.scene_paths[scene]["type"] == SceneManager.SceneTypes.UI:
		await get_tree().create_timer(0.01).timeout
		Bus.loading_screen_finished.emit()
		finished = true
		return
	
	show()
	completion = 0.0
	label.text = str(0)
	loading_circle.material.set_shader_parameter("progress", completion)
	target_add = 0.0
	finished = false
