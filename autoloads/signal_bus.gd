extends Node

signal beat_press_attempted

signal beat(beat_count: int)

signal beat_success(level: int)
signal beat_success_to_circle(level: int, circle: TimingCircle, element: int)
signal beat_success_to_spellcast(element: int)
signal beat_failure

signal fade_out_ended
signal fade_in_ended

signal level_done_generating
signal level_layout_ready
signal loading_screen_finished
signal loading_level
signal level_exited

signal player_moved
signal player_took_damage(origin: Node3D)
signal player_lost_hp
signal player_cast(elements: Array[int], success: String)
signal player_used_combo(combo: StringName)
signal not_enough_dopamine

signal succesful_interact
signal succesful_move_forward

signal spell_landed(elements: Array[int])

signal synapse_picked_up
signal neuron_picked_up
signal item_picked_up(item: Vars.item_types)
signal item_removed(item: Vars.item_types)

signal enemy_died(enemy: Enemy)
signal necessary_enemies_died(puzzle_id: int)

signal game_won
signal game_lost
