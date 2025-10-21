extends Node

signal beat_press_attempted

signal any_beat

signal first_of_two_beats
signal second_of_two_beats

signal first_of_four_beats
signal third_of_four_beats
signal fourth_of_four_beats

signal first_of_eight_beats

signal first_of_twelve_beats

signal beat_success(level: int)
signal beat_success_to_circle(level: int, circle: TimingCircle, element: int)
signal beat_success_to_spellcast(element: int)
signal beat_failure

signal player_moved
signal player_lost_hp
