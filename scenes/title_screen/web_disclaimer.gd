extends Label


func _ready() -> void:
	if not OS.get_name() == "Web":
		return
	
	show()
