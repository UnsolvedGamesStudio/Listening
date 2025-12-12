extends CanvasLayer


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#var screen_middle:= get_viewport().get_visible_rect().size
	#var mouse_pos:= Vector2(screen_middle.x, screen_middle.y * 1.5)
	#Input.warp_mouse(mouse_pos)
