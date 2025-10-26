extends CanvasLayer
##Todo: add a pause/unpause sigil
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var waiting_for_beat:= false


func _ready() -> void:
	Bus.beat.connect(on_beat)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()
	
	if not event.is_action_pressed("pause"):
		return
	
	if Vars.paused == false:
		pause()
	
	if Vars.paused == true:
		waiting_for_beat = true


func pause():
	animation_player.play("pop_in")
	await get_tree().create_timer(0.0, true, false, true).timeout
	Bgm.bus = "PauseMenuMusic"
	get_tree().paused = true
	Vars.paused = true
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func unpause():
	animation_player.play("pop_out")
	Bgm.bus = "BGM"
	get_tree().paused = false
	Vars.paused = false
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	waiting_for_beat = false


func on_beat(beat):
	if waiting_for_beat == false or Vars.paused == false:
		return
	
	unpause()
