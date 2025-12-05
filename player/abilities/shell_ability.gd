extends PlayerAbility
class_name ShellAbility
## Todo: indicate remaining duration
const SHELL_OBJECT = preload("uid://b63ny4wig2srm")

@onready var timer: Timer = %Timer

@export var duration:= 10.0
var active:= false
var active_shell: ShellObject


func activate():
	if active == true:
		active_shell.heal(active_shell.max_hp / 2)
		return
	
	active = true
	timer.start(duration)
	var shell_inst: Node3D = SHELL_OBJECT.instantiate()
	shell_inst.ability = self
	active_shell = shell_inst
	player.get_parent().add_child(shell_inst)
	tween_pop_up(shell_inst)
	shell_inst.global_position = player.global_position
	shell_inst.global_rotation.y = player.camera.global_rotation.y


func tween_pop_up(shell_inst):
	var tween_length: float = Bgm.rhythm_notifier.beat_length / 2
	
	shell_inst.mesh_instance_3d.scale.x = 0.01
	shell_inst.mesh_instance_3d.scale.z = 0.01
	
	var tween:= create_tween()
	tween.parallel().tween_property(shell_inst.mesh_instance_3d, "scale", Vector3(0.1, 0.1, 0.1), tween_length / 4)
	tween.tween_property(shell_inst.mesh_instance_3d, "scale:z", 1.0, tween_length)
	tween.tween_property(shell_inst.mesh_instance_3d, "scale:x", 1.0, tween_length)
	tween.parallel().tween_property(shell_inst.mesh_instance_3d, "scale:z", 1.0, tween_length)
	
	await tween.finished
	
	shell_inst.finished_appearing = true


func tween_shrink(shell_inst):
	var tween_length: float = Bgm.rhythm_notifier.beat_length / 2
	var tween:= create_tween()
	tween.tween_property(shell_inst.mesh_instance_3d, "scale:x", 0.1, tween_length)
	tween.tween_property(shell_inst.mesh_instance_3d, "scale:z", 0.1, tween_length)
	tween.parallel().tween_property(shell_inst.mesh_instance_3d, "scale:x", 0.1, tween_length)
	tween.tween_property(shell_inst.mesh_instance_3d, "scale", Vector3(0.01, 0.01, 0.01), tween_length / 4)
	
	await tween.finished


func _on_timer_timeout() -> void:
	if active_shell == null:
		return
	
	await tween_shrink(active_shell)
	
	active_shell.queue_free()
	active_shell = null
	active = false
