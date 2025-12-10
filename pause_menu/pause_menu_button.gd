extends Button

@export var type: types
enum types {RESUME, EXIT, PLAY_AGAIN, HUB, RESET}


func _ready() -> void:
	button_up.connect(on_button_up)
	mouse_entered.connect(on_mouse_entered)
	button_down.connect(on_button_down)


func on_mouse_entered():
	GlobalSfx.ui_hover.play()


func on_button_down():
	GlobalSfx.ui_click.play()


func on_button_up():
	if type == types.RESUME:
		if owner.has_method("unpause_attempt"):
			owner.unpause_attempt()
	
	if type == types.EXIT:
		SceneManager.quit_game()
	
	if type == types.PLAY_AGAIN:
		if owner.has_method("unpause"):
			GlobalSfx.rewind.play()
			owner.unpause()
		
		SceneManager.reload_level()
	
	if type == types.HUB:
		if owner.has_method("unpause"):
			GlobalSfx.rewind.play()
			owner.unpause()
		
		SceneManager.change_scene(SceneManager.Scenes.HUB_WORLD)
		Bgm.stop_song()
	
	if type == types.RESET:
		SaveManager.erase_all_save_data()
