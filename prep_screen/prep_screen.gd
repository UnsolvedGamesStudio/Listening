extends CanvasLayer


func _ready() -> void:
	Filters.fade.play("fade_in")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await Filters.fade.animation_finished
