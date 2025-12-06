extends Pickup
class_name RemembererPickup
## Todo: Add safety check to make sure no forgetters are remaining, to prevent softlocks
@onready var label: Label = %Label

var original_position:= Vector3.ZERO

var puzzle_id:= -1
var required_synapses:= 11


func enter():
	label.text = str(required_synapses)
	
	await Bus.level_done_generating
	
	original_position = global_position
	


func looked_at_by_player(on: bool):
	if on == true:
		if Vars.synapses >= required_synapses:
			sprite_3d.modulate = Color(0.409, 0.84, 0.0, 1.0)
		else:
			sprite_3d.modulate = Color(0.726, 0.0, 0.026, 1.0)
	
	else:
		sprite_3d.modulate = Color(1.0, 1.0, 1.0, 1.0)


func activate():
	if Vars.synapses >= required_synapses:
		remembember_all_forgetters()
		SaveManager.save_position("rememberer", global_position)
	
	else:
		animation_player.play("bounce")


func remembember_all_forgetters():
	for forgetter in Vars.forgetters:
		if not is_instance_valid(forgetter):
			return
		
		if forgetter.puzzle_id == puzzle_id:
			forgetter.remember()
	
	vanish()
