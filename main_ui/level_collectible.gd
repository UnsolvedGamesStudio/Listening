extends HBoxContainer


func _ready() -> void:
	SceneManager.call_deferred("hide_node_in_hub", self, SceneManager.Scenes.HUB_WORLD)
