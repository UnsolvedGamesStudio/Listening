extends Label


func _physics_process(delta: float) -> void:
	if SceneManager.is_current_scene(SceneManager.Scenes.HUB_WORLD):
		text = str(Vars.neurons)
	else:
		text = str(Vars.neurons, "/", Vars.total_neurons)
