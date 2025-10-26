extends Node
class_name EnemyDataLoader


func load_data():
	var O: Enemy = owner
	
	if O == null:
		printerr(self, ": owner not found")
		return
	
	O.sprite_3d.texture = get_data().texture
	O.sprite_3d.scale = get_data().sprite_scale
	
	O.preferred_range = get_data().preferred_range
	O.body_damage = get_data().body_damage
	O.impassable = get_data().impassable
	O.vision_limit = get_data().vision_limit
	
	## Todo: Appearance data loads that don't get overriden by animation player
	#O.to_animate.global_position.y = get_data().y_position

	add_behaviors()


func add_behaviors():
	var O: Enemy = owner
	var behaviors_container: Node = O.behaviors_container
	
	if get_data() == null:
		return
	
	for behavior: NodePath in get_data().behaviors:
		var behavior_inst = load(behavior).instantiate()
		
		behavior_inst.O = O
		behaviors_container.add_child(behavior_inst)


func get_data():
	var O: Enemy = owner
	
	if O == null:
		printerr(self, ": owner not found")
		return
	
	var data: EnemyResource = O.data
	
	if data == null:
		printerr(self, " of ", O, ": data not found")
		return
	
	return data
