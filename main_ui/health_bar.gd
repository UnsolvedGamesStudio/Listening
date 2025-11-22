extends ProgressBar

@onready var health_bar_label: Label = %HealthBarLabel


func _physics_process(delta: float) -> void:
	update_value()


func update_value():
	max_value = Find.P().max_hp / 100
	value = lerp(value, Find.P().hp / 100, 0.33)
	get_theme_stylebox("fill").bg_color.r = max_value - value
	get_theme_stylebox("fill").bg_color.g = value
	health_bar_label.text = str(Find.P().hp as int)
