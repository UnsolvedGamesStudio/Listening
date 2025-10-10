extends ColorRect

@onready var animation_player: AnimationPlayer = %AnimationPlayer

@onready var label: Label = $"../Label"


func _ready() -> void:
	Bus.beat_played.connect(pulse)


func _physics_process(delta: float) -> void:
	if Bgm.closeness > 0.6:
		modulate = Color(0.5, 1, 1)
	else:
		modulate = Color(1, 1, 1)


func pulse():
	animation_player.play("pulse")


func _input(event: InputEvent) -> void:
	var damage:= 0
	
	if not event.is_action_pressed("left_click"):
		return
	
	label.text = str(Bgm.check_accuracy())
	
	await get_tree().create_timer(0.4).timeout
	
	label.text = ""
	
	Bus.player_attacked.emit(damage)
