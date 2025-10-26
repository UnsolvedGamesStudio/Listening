extends Label


func _physics_process(delta: float) -> void:
	text = str("Enemies left: ", Vars.living_enemies.size())
