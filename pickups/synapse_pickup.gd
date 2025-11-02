extends Pickup
class_name SynapsePickup

func enter():
	Vars.synapses_left += 1


func on_activated():
	Vars.synapses += 1
	Bus.synapse_picked_up.emit()
	
	if Vars.synapses == Vars.synapses_left:
		Bus.game_won.emit()
