extends Node

#enum TimeableInputs {
	#ELEMENT,
	#CAST,
	#INTERACT,
	#MOVE
#}
#
#enum TimingModes {
	#BEAT_REQUIRED,
	#BEAT_BONUS_ADDED,
	#BEAT_IGNORED
	#}
#
#var input_attributes: Dictionary[TimeableInputs, Dictionary] = {
	#TimeableInputs.ELEMENT : {
		#"timing_mode" : TimingModes.BEAT_REQUIRED,
		#"breaks_combo" : true,
		#"free_time_cooldown" : 0.1
		#},
	#
	#TimeableInputs.CAST : {
		#"timing_mode" : TimingModes.BEAT_REQUIRED,
		#"breaks_combo" : true,
		#"free_time_cooldown" : 0.1
		#},
	#
	#TimeableInputs.INTERACT : {
		#"timing_mode" : TimingModes.BEAT_BONUS_ADDED,
		#"breaks_combo" : true,
		#"free_time_cooldown" : 0.1
		#},
	#
	#TimeableInputs.MOVE : {
		#"timing_mode" : TimingModes.BEAT_BONUS_ADDED,
		#"breaks_combo" : true,
		#"free_time_cooldown" : 0.1
		#},
#}
#
#
#func valid_input(input_type: TimeableInputs) -> bool:
	#if input_attributes[input_type]["timing_mode"] == TimingModes.BEAT_IGNORED:
		#return true
	#
	#if input_attributes[input_type]["timing_mode"] == TimingModes.BEAT_REQUIRED:
		#valid_timing()
		#return true
	#
	#return false
#
#
#func valid_timing():
	## "if timing good: increase_bonus()"
	#
	#pass
#
#
#func increase_bonus():
	#pass
#
#
#func reset_bonus():
	#Vars.combo = 0
