extends CanvasLayer
## Todo: add a pause/unpause sigil
## Todo: add a tiny swipe clock to show when unpause will happen
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var back_to_hub_button: Button = %BackToHubButton

var waiting_for_beat:= false


func _ready() -> void:
	Bus.beat.connect(on_beat)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		SceneManager.quit_game()
	
	if not event.is_action_pressed("pause"):
		return
	
	if Vars.paused == false:
		pause()
	
	if Vars.paused == true:
		unpause_attempt()


func pause():
	if SceneManager.current_scene is HubWorld:
		back_to_hub_button.hide()
	else:
		back_to_hub_button.show()
	
	animation_player.play("pop_in")
	Filters.pause_shader_fade.play("fade_in")
	await get_tree().create_timer(0.0, true, false, true).timeout
	Bgm.bus = "PauseMenuMusic"
	get_tree().paused = true
	Vars.paused = true
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func unpause_attempt():
	GlobalSfx.rewind.play()
	
	if Bgm.playing == true:
		waiting_for_beat = true
		return
	
	unpause()


func unpause():
	animation_player.play("pop_out")
	Filters.pause_shader_fade.play("fade_out")
	Bgm.bus = "BGM"
	get_tree().paused = false
	Vars.paused = false
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	waiting_for_beat = false


func take_off_filter():
	Filters.pause_shader_fade.play("fade_out")


func on_beat(beat):
	if waiting_for_beat == false:
		return
	
	unpause()
