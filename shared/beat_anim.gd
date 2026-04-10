extends AnimationPlayer

enum Methods {_2_FRAMES, RESET, SEQUENCE}

@export var method: Methods = Methods._2_FRAMES
@export var adapt_to_bpm:= false


func _ready() -> void:
	Bus.beat.connect(on_beat)


func _2_frames():
	if current_animation == "1":
		play("2")
	else:
		play("1")


func reset():
	stop()
	play("1")


func on_beat(_beat_count: int):
	if adapt_to_bpm:
		speed_scale = 0.3 * (Bgm.beat_timer.bpm / 100)
	
	if method == Methods._2_FRAMES:
		_2_frames()
	
	if method == Methods.RESET:
		reset()
