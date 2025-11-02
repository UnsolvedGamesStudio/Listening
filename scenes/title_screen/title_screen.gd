extends Node3D


func _ready() -> void:
	Filters.fade.play("fade_in")
	await get_tree().create_timer(0.25).timeout
	Bgm.non_beat_bgm.play()
