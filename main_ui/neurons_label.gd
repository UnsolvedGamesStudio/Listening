extends Label


func _physics_process(delta: float) -> void:
	text = str(Vars.neurons, "/", Vars.total_neurons)
