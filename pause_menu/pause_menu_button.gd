extends Button
##Todo: hide_in_hub group
enum types {RESUME, EXIT, PLAY_AGAIN, HUB, RESET}

@export var type: types
@export var hide_in_hub:= false
@export var confirm_label: Label

func _ready() -> void:
	button_up.connect(on_button_up)
	mouse_entered.connect(on_mouse_entered)
	button_down.connect(on_button_down)
	
	if hide_in_hub == true:
		SceneManager.call_deferred("hide_node_in_hub", self, SceneManager.Scenes.HUB_WORLD)


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
	
	pop_up_confirm()


func pop_up_confirm():
	if not confirm_label:
		return
	
	confirm_label.show()
	await get_tree().create_timer(1.0, true, false, true).timeout
	confirm_label.hide()
