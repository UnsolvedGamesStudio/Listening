extends CPUParticles3D


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
