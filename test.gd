extends ColorRect

@onready var animation_player: AnimationPlayer = %AnimationPlayer

@onready var label: Label = $"../Label"

@export var window:= 0.35
var closeness:= 0.0


func _ready() -> void:
	Bus.beat_played.connect(pulse)


func _physics_process(delta: float) -> void:
	closeness = BeatVars.frames_since_last_beat / 30.0
	if closeness > window:
		modulate = Color(0.5, 1, 1)
	else:
		modulate = Color(1, 1, 1)


func pulse():
	animation_player.play("pulse")
	#timer.start()


func _input(event: InputEvent) -> void:
	var message:= "Missed..."
	var damage:= 0
	
	if not event.is_action_pressed("ui_accept"):
		return
	
	#if timer.is_stopped():
		#return
	
	closeness = BeatVars.frames_since_last_beat / 30.0
	
	print(closeness)
	
	if closeness <= window + 0.15:
		message = "Ok!"
		damage = 10
		
	if closeness <= window:
		message = "Nice!"
		damage = 15
		
	if closeness <= window - 0.15:
		message = "Excellent!"
		damage = 25
	
	label.text = str(message, "(", int(closeness * 100), "/100)")
	await get_tree().create_timer(window * 4).timeout
	label.text = ""
	
	Bus.player_attacked.emit(damage)
