extends Pickup
class_name NeuronPickup


func on_activated():
	Vars.neurons += 1
	Bus.neuron_picked_up.emit()
	
	if Vars.neurons == Vars.total_neurons:
		Bus.game_won.emit()
