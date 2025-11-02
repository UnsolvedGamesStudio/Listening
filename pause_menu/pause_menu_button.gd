extends Button

@export var type: types
enum types {RESUME, EXIT, PLAY_AGAIN}


func _ready() -> void:
	button_up.connect(on_button_up)


func on_button_up():
	if type == types.RESUME:
		if owner.has_method("unpause_attempt"):
			owner.unpause_attempt()
	
	if type == types.EXIT:
		get_tree().quit()
	
	if type == types.PLAY_AGAIN:
		SceneManager.reload_game()
