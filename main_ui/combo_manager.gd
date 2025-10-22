extends Label
class_name combo_manager

@onready var score_label: Label = %ScoreLabel


func _ready() -> void:
	Bus.beat_success.connect(on_beat_success)
	Bus.beat_failure.connect(on_beat_failure)


func on_beat_success(level: int):
	Vars.combo += 1
	Vars.score += level + 10
	text = str("x", Vars.combo)
	score_label.text = str("Score: ", roundi(Vars.score))


func on_beat_failure():
	Vars.combo = 0
	Vars.score = 0.0
	text = str("x", Vars.combo)
	score_label.text = str("Score: ", roundi(Vars.score))
