extends CheckButton


func _ready() -> void:
	toggled.connect(on_toggled)


func on_toggled(toggled_on: bool):
	if toggled_on == false:
		Find.P().auto_move = true
	
	if toggled_on == true:
		Find.P().auto_move = false
