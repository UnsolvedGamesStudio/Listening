extends ColorRect

@onready var animation_player: AnimationPlayer = %AnimationPlayer

@onready var label: Label = $"../Label"
@onready var timer: Timer = $"../Timer"

@export var window:= 0.2
var closeness:= 0.0


func _ready() -> void:
	Bus.beat_played.connect(pulse)
	timer.wait_time = window


func _physics_process(delta: float) -> void:
	if timer.is_stopped():
		modulate = Color(0.5, 1, 1)
	else:
		modulate = Color(1, 1, 1)


func pulse():
	animation_player.play("pulse")
	timer.start()


func _input(event: InputEvent) -> void:
	var message:= "Meh..."
	var damage:= 5
	
	if not event.is_action_pressed("ui_accept"):
		return
	
	if timer.is_stopped():
		return
	
	closeness = timer.time_left / timer.wait_time
	
	if closeness >= 0.25:
		message = "Ok!"
		damage = 10
		
	if closeness >= 0.5:
		message = "Nice!"
		damage = 15
		
	if closeness >= 0.75:
		message = "Excellent!"
		damage = 25
	
	label.text = str(message, "(", int(closeness * 100), "/100)")
	await get_tree().create_timer(window * 1.5).timeout
	label.text = ""
	
	Bus.player_attacked.emit(damage)
