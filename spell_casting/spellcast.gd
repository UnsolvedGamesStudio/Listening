extends Node

@onready var label: Label = $Label

func _ready() -> void:
	Bus.beat_success_to_spellcast.connect(on_beat_success_to_spellcast)


func cast_spell():
	var container:= Vars.element_container
	
	if container == []:
		return
	
	container.clear()
	label.text = str("Cast!")
	await get_tree().create_timer(0.4).timeout
	label.text = ""


func on_beat_success_to_spellcast(level, element: String):
	if element == "none":
		cast_spell()
		return
	
	var container:= Vars.element_container
	
	if container.size() >= 3:
		container.clear()
	
	container.append(element)
	label.text = str(container)
