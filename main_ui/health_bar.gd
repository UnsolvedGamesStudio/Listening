extends ProgressBar


func _physics_process(delta: float) -> void:
	update_value()


func update_value():
	max_value = Find.P().max_hp / 100
	value = lerp(value, Find.P().hp / 100, 0.33)
	modulate.r = max_value - value
	modulate.g = value
