extends Button

@export var type: types
enum types {RESUME, EXIT}


func _ready() -> void:
	button_up.connect(on_button_up)


func on_button_up():
	if type == types.RESUME:
		if owner.has_method("unpause"):
			owner.unpause()
	
	if type == types.EXIT:
		get_tree().quit()
