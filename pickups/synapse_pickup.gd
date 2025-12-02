extends Pickup
class_name SynapsePickup

@onready var sfx: AudioStreamPlayer = %SFX

var category:= "synapses"


func enter():
	Vars.total_synapses += 1


func on_activated():
	sfx.reparent(get_parent())
	sfx.play()
	Vars.synapses += 1
	SaveManager.set_collected(category, uuid)
	Bus.synapse_picked_up.emit()
