extends Node

#var current_state: states
#
#signal state_changed(old_state, new_state)
#
#
#enum states {
	#TITLE_SCREEN,
	#TEST_LEVEL,
	#LAYOUT,
	#HUB_WORLD,
	#NONE,
	#PREP_SCREEN,
	#GENERATING_LEVEL,
	#PAUSED,
#}
#
#
#func enter_state(from: states, to: states):
	#current_state = to
	#state_changed.emit(from, to)
#
#
#func get_scene_for_state(state: states):
	#var returned_scene: PackedScene
	#
	#if state == states.TITLE_SCREEN:
		#returned_scene = preload("uid://bqk51arvtg2x")
	#
	#if state == states.TEST_LEVEL:
		#returned_scene = preload("uid://ut6wqeoatv1w")
	#
	#if state == states.HUB_WORLD:
		#returned_scene = preload("uid://bb0is713hmgcy")
	#
	#if state == states.PREP_SCREEN:
		#returned_scene = preload("uid://cglbfa3a2dw7v")
	#
	#if state == states.LAYOUT:
		#returned_scene = preload("uid://d1rnngxhnemng")
	#
	#return returned_scene
