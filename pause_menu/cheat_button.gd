extends CheckButton


func _ready() -> void:
	toggled.connect(on_toggled)
	mouse_entered.connect(on_mouse_entered)


func on_mouse_entered():
	GlobalSfx.ui_hover.play()


func on_toggled(toggled_on: bool):
	GlobalSfx.ui_click.play()
	
	if toggled_on == false:
		Find.P().invincible_cheat = false
	
	if toggled_on == true:
		Find.P().invincible_cheat = true
