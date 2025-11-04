extends Pickup
class_name RemembererPickup
## Todo: create cloud particles in place of forgotten
@onready var label: Label = %Label

var puzzle_id:= -1
var required_synapses:= 11


func enter():
	label.text = str("🧠 ", required_synapses)


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
	
	else:
		animation_player.play("bounce")


func remembember_all_forgetters():
	for forgetter in Vars.forgetters:
		
		if forgetter.puzzle_id == puzzle_id:
			forgetter.remember()
	
	vanish()
