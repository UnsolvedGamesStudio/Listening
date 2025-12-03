extends GPUParticles3D

@export var scale_mult:= 1.0
@export var particle_size:= 1.0
@export var texture: Texture


func _ready() -> void:
	scale *= scale_mult
	draw_pass_1.size *= particle_size


func activate(time:= 0.2, destroy:= true):
	var layout:= Find.layout()
	
	if not get_parent() == layout:
		reparent(layout)
	
	emitting = true
	await get_tree().create_timer(time).timeout
	emitting = false
	
	await finished
	
	if destroy == true:
		queue_free()
