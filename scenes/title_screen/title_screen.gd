extends Node3D


func _ready() -> void:
	var main: SceneManager = get_tree().get_first_node_in_group("main_scene")
	main.fade.play("fade_in")
	await get_tree().create_timer(0.25).timeout
	Bgm.non_beat_bgm.play()
