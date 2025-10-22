extends VBoxContainer
class_name ElementContainerUI

@onready var element_1: TextureRect = %Element1
@onready var element_2: TextureRect = %Element2
@onready var element_3: TextureRect = %Element3

@onready var element_expiry_timer: Timer = %ElementExpiryTimer
@onready var timer_bar: ProgressBar = %TimerBar


func _physics_process(delta: float) -> void:
	if element_expiry_timer.is_stopped():
		return
	
	timer_bar.value = element_expiry_timer.time_left / element_expiry_timer.wait_time
	timer_bar.modulate.r = timer_bar.max_value - timer_bar.value
	timer_bar.modulate.g = timer_bar.value


func update():
	var first_in_container
	
	if Vars.element_container == []:
		timer_bar.value = 0.0
		element_expiry_timer.stop()
	
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
