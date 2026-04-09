extends Pickup
class_name SynapsePickup
## Todo: Add level name to save ID
@onready var sfx: AudioStreamPlayer = %SFX

var category:= SaveManager.DataType.SYNAPSES


func enter():
	Vars.total_synapses += 1


func on_activated():
	sfx.reparent(get_parent())
	sfx.play()
	Vars.synapses += 1
	SaveManager.set_collected(category, save_id)
	Bus.synapse_picked_up.emit()
