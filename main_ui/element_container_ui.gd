extends VBoxContainer
class_name ElementContainerUI

@onready var element_1: TextureRect = %Element1
@onready var element_2: TextureRect = %Element2
@onready var element_3: TextureRect = %Element3


func update():
	var first_in_container
	if Vars.element_container.size() > 0:
		first_in_container = Vars.element_container[0]
	
	var second_in_container
	if Vars.element_container.size() > 1:
		second_in_container = Vars.element_container[1]
	
	var third_in_container
	if Vars.element_container.size() > 2:
		third_in_container = Vars.element_container[2]
	
	if not first_in_container == null:
		element_1.texture = Vars.elements[first_in_container].texture
	else:
		element_1.texture = null
	
	if not second_in_container == null:
		element_2.texture = Vars.elements[second_in_container].texture
	else:
		element_2.texture = null
	
	if not third_in_container == null:
		element_3.texture = Vars.elements[third_in_container].texture
	else:
		element_3.texture = null
