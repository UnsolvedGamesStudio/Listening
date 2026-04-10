extends Label


func _ready() -> void:
	if OS.has_feature("editor"):
		show()
