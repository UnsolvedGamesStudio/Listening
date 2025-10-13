extends Node

@onready var label: Label = $Label
var container:= Vars.element_container


func _ready() -> void:
	Bus.beat_success_to_spellcast.connect(on_beat_success_to_spellcast)


func _input(event: InputEvent) -> void:
	on_cast_pressed(event)
	on_element_pressed(event)


func on_cast_pressed(event: InputEvent):
	if not event.is_action_pressed("cast"):
		return
	
	Bgm.check_accuracy()


func on_element_pressed(event: InputEvent):
	var picked_element
	
	if event.is_action_pressed("element_1"):
		picked_element = "fire"
	
	elif event.is_action_pressed("element_2"):
		picked_element = "ice"
	
	elif event.is_action_pressed("element_3"):
		picked_element = "lightning"
	
	if picked_element == null:
		return
	
	Bgm.check_accuracy(picked_element)


func cast_spell():
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
	
	if container.size() >= 3:
		container.clear()
	
	container.append(element)
	label.text = str(container)
