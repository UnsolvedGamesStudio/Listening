extends CanvasLayer

var paused:= false
@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()
	
	if not event.is_action_pressed("pause"):
		return
	
	if paused == false:
		pause()
	
	if paused == true:
		unpause()


func pause():
	animation_player.play("pop_in")
	await get_tree().create_timer(0.0, true, false, true).timeout
	Bgm.animation_player.play("pause_menu_music_volume")
	get_tree().paused = true
	paused = true
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func unpause():
	animation_player.play("pop_out")
	get_tree().paused = false
	Bgm.animation_player.play_backwards("pause_menu_music_volume")
	paused = false
	Bgm.pause_menu_music.volume_db = -80.0
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
