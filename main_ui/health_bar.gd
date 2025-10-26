extends ProgressBar

func _ready() -> void:
	#Bus.player_hp_changed.connect(on_player_hp_changed)
	update_value()


func _physics_process(delta: float) -> void:
	update_value()


func update_value():
	max_value = Find.P().max_hp / 100
	value = Find.P().hp / 100
	modulate.r = max_value - value
	modulate.g = value


func on_player_hp_changed():
	update_value()
