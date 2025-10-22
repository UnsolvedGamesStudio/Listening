extends Node

signal beat_press_attempted

signal beat(beat_count: int)

signal beat_success(level: int)
signal beat_success_to_circle(level: int, circle: TimingCircle, element: int)
signal beat_success_to_spellcast(element: int)
signal beat_failure

signal player_moved
signal player_lost_hp
