extends Label


func _physics_process(delta: float) -> void:
	text = str(Vars.synapses, "/", Vars.total_synapses)
