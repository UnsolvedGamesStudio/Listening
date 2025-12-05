extends Label

var current_time: float = 0.0


func _ready() -> void:
	call_deferred("hide_in_hub")


func hide_in_hub():
	if SceneManager.current_scene.is_in_group("layout"):
		hide()
	else:
		show()


func _process(delta: float) -> void:
	current_time += delta
	text = convert_time_to_string(current_time)


static func convert_time_to_string(time: float) -> String:
	var hours: int = int(time / (60.0 * 60.0))
	var minutes: int = int(time / 60.0) % 60
	var seconds: int = int(time) % 60
	#var centiseconds: int = int(time * 100.0) % 100
	var string: String = str(seconds as int)
	#var string: String = "%02d.%02d" % [seconds, centiseconds]
	
	if minutes > 0 or hours > 0:
		string = string.insert(0, ("%02d:" if hours > 0 else "%d:") % minutes)
	if hours > 0:
		string = string.insert(0, "%d:" % hours)
	
	return string
