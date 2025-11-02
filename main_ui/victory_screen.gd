extends CanvasLayer


func _ready() -> void:
	Bus.game_won.connect(on_game_won)


func on_game_won():
	var tween:= create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	Bgm.bus = "PauseMenuMusic"
	pop_in()
	tween.tween_property(Engine, "time_scale", 0.0, 1.5)
	tween.tween_callback(pause)


func pause():
	get_tree().paused = true
	Vars.paused = true


func pop_in():
	await get_tree().create_timer(0.5, true, false, true).timeout
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var tween:= create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_ignore_time_scale(true)
	tween.tween_property(self, "offset:y", 0.0, 0.5)
