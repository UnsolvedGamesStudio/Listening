extends Node3D

@onready var title_appear: AnimationPlayer = %TitleAppear


func _ready() -> void:
	Filters.fade.play("fade_in")
	title_appear.play("appear")
	await get_tree().create_timer(0.25).timeout
	Bgm.non_beat_bgm.play()
