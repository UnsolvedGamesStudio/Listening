extends Label
class_name ComboManager

@onready var score_label: Label = %ScoreLabel


func _ready() -> void:
	Bus.beat_success.connect(on_beat_success)
	Bus.beat_failure.connect(on_beat_failure)
	Bus.synapse_picked_up.connect(on_synapse_picked_up)


func update_label():
	text = str("x", Vars.combo)
	score_label.text = str("Dmg bonus: ", roundi(min(100.0, Vars.score / 20.0) ) )


func on_beat_success(level: int):
	Vars.combo += 1
	Vars.score += level + 10
	update_label()


func on_beat_failure():
	Vars.combo = 0
	Vars.score = 0.0
	update_label()


func on_synapse_picked_up():
	Vars.score += 5
	Vars.score *= 1.2
	update_label()
