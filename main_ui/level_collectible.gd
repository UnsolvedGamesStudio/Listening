extends HBoxContainer

func _ready() -> void:
	call_deferred("hide_in_hub")


func hide_in_hub():
	if SceneManager.current_scene is HubWorld:
		hide()
	else:
		show()
