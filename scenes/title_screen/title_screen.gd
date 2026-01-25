extends Node3D

@onready var title_appear: AnimationPlayer = %TitleAppear


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	title_appear.play("appear")
	Bgm.non_beat_bgm.play()
