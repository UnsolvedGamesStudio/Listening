extends CanvasLayer

@onready var loading_circle: TextureRect = %LoadingCircle
@onready var label: Label = %Label
@onready var disappear: AnimationPlayer = %Disappear
@onready var wobble: AnimationPlayer = %Wobble
@onready var dots_wobble: AnimationPlayer = %DotsWobble

var completion: float = 0.0

var previous_value:= 0.0
var target_add:= 0.0

var finished:= true


func _ready() -> void:
	hide()


func _process(delta: float) -> void:
	if finished == true:
		return
	
	var target:= 0.0
	
	target = set_target_value()
	
	completion = move_toward(completion, target, delta * 2)
	loading_circle.material.set_shader_parameter("progress", completion)
	label.text = str( roundi( min( 100.0, completion * 100.0 ) ) )
	
	if completion == previous_value:
		target_add += 0.01
	
	previous_value = completion
	
	if completion >= 1.0 and SceneManager.current_loading_progress >= 1.0:
		finished = true
		wobble.stop()
		disappear.play("shrink")
		await disappear.animation_finished
		Bus.loading_screen_finished.emit()
		hide()


func set_target_value():
	if SceneManager.loading_in_progress == true:
		return SceneManager.current_loading_progress + target_add
	else:
		return 1.0


func start():
	if get_tree().get_first_node_in_group("main_scene").disable_loading_screen:
		return
	
	disappear.play("RESET")
	show()
	wobble.play("wobble")
	dots_wobble.play("wobble")
	completion = 0.0
	target_add = 0.0
	label.text = str( roundi( min( 100.0, completion * 100.0 ) ) )
	loading_circle.material.set_shader_parameter("progress", 0.0)
	finished = false
