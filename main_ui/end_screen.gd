extends CanvasLayer

@onready var header: Label = %Header
@onready var body: Label = %Body


func _ready() -> void:
	Bus.game_won.connect(on_game_won)
	Bus.game_lost.connect(on_game_lost)


func on_game_won():
	header.text = "Congratulations!"
	body.text = "You are starting to remember."
	appear()


func on_game_lost():
	header.text = "Sorry for your loss."
	body.text = "You get another chance."
	appear()


func appear():
	var tween:= create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	Bgm.bus = "PauseMenuMusic"
	pop_in()
	tween.tween_property(Engine, "time_scale", 0.0, 1.5)
	tween.tween_callback(pause)


func disappear():
	var tween:= create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	Bgm.bus = "BGM"
	pop_out()
	tween.tween_property(Engine, "time_scale", 1.0, 0.5)


func pause():
	get_tree().paused = true
	Vars.paused = true


func unpause():
	disappear()
	Filters.pause_shader_fade.play("fade_out")
	Bgm.bus = "BGM"
	get_tree().paused = false
	Vars.paused = false
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func pop_in():
	await get_tree().create_timer(0.5, true, false, true).timeout
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var tween:= create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_ignore_time_scale(true)
	tween.tween_property(self, "offset:y", 0.0, 0.5)


func pop_out():
	var tween:= create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_ignore_time_scale(true)
	tween.tween_property(self, "offset:y", 0.0, 0.5)
