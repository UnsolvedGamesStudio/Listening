extends Pickup
class_name NeuronPickup

@onready var sfx: AudioStreamPlayer = %SFX


func _ready() -> void:
	Vars.total_neurons += 1


func on_activated():
	Vars.neurons += 1
	Bus.neuron_picked_up.emit()
	
	if Vars.neurons == Vars.total_neurons:
		sfx.reparent(get_parent())
		sfx.play()
		Bus.game_won.emit()
