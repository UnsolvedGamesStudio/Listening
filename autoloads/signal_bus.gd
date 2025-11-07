extends Node

signal beat_press_attempted

signal beat(beat_count: int)

signal beat_success(level: int)
signal beat_success_to_circle(level: int, circle: TimingCircle, element: int)
signal beat_success_to_spellcast(element: int)
signal beat_failure

signal player_moved
signal player_took_damage(origin: Node3D)
signal player_lost_hp
signal player_cast(elements: Array[int], success: String)

signal spell_landed(elements: Array[int])

signal synapse_picked_up
signal neuron_picked_up
signal item_picked_up(item: Vars.item_types)
signal item_removed(item: Vars.item_types)

signal game_won
signal game_lost
