extends Button

@export_enum("exit") var type:= "resume"


func _ready() -> void:
	button_up.connect(on_button_up)


func on_button_up():
	if type == "resume":
		if owner.has_method("unpause"):
			owner.unpause()
	
	if type == "exit":
		get_tree().quit()
