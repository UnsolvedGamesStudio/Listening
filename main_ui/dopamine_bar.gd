extends ProgressBar

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var dopamine_bar_label: Label = %DopamineBarLabel


func _ready() -> void:
	Bus.not_enough_dopamine.connect(on_not_enough_dopamine)


func _physics_process(delta: float) -> void:
	update_value()


func update_value():
	max_value = Vars.max_dopamine / 100
	value = lerp(value, Vars.dopamine / 100, 0.33)
	dopamine_bar_label.text = str(Vars.dopamine)


func on_not_enough_dopamine():
	animation_player.play("not_enough")
