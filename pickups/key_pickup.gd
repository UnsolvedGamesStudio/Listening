extends Pickup
class_name KeyPickup

@onready var sfx: AudioStreamPlayer = %SFX

var key_type: Vars.item_types = Vars.item_types.F_KEY


func on_activated():
	if key_type in Vars.inventory:
		Vars.inventory[key_type]["amount"] += 1
	
	else:
		Vars.inventory[key_type] = {
			"texture" : sprite_3d.texture,
			"amount" : 1
		}
	
	sfx.reparent(get_parent())
	sfx.play()
	Bus.item_picked_up.emit(key_type)
