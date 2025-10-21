extends Label
class_name combo_manager


func _ready() -> void:
	Bus.beat_success.connect(on_beat_success)
	Bus.beat_failure.connect(on_beat_failure)


func on_beat_success(level: int):
	Vars.combo += 1
	text = str("x", Vars.combo)


func on_beat_failure():
	Vars.combo = 0
	text = str("x", Vars.combo)
