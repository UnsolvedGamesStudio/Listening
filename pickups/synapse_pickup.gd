extends Pickup
class_name SynapsePickup


func enter():
	Vars.total_synapses += 1


func on_activated():
	Vars.synapses += 1
	Bus.synapse_picked_up.emit()
