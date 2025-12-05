extends RigidBody3D
class_name Critter

var free_timer:= Timer.new()
var dead:= false


func _ready() -> void:
	enter()
	add_child(free_timer)
	
	await Bus.level_layout_ready
	
	level_ready()


func enter():
	pass


func level_ready():
	pass


func die():
	dead = true
	on_die()


func on_die():
	pass


func destroy(after_time:= 100.0):
	if after_time == 0.0:
		queue_free()
	
	free_timer.start(after_time)
	await free_timer.timeout
	queue_free()
