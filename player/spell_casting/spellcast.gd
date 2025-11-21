extends Node
## Todo: Make empty sample note be based on camera rotation so you can actually play music
## Todo: Make the first element get replaced instead of the last
@onready var label: Label = $Label

const CAST_SIGIL = preload("uid://c5nwti415vrqj")
const EMPTY_CAST_SIGIL = preload("uid://cquqsopjsxe0b")
const DEFAULT_SPELL = preload("uid://d0jjxcbead86g")

const PROJECTILE = preload("uid://bxvo7ewsxt46f")

@export var spell_range_mult:= 1.0

var element_expiry_time_mult:= 20.0
var container:= Vars.element_container


func _input(event: InputEvent) -> void:
	if get_parent().can_act == false:
		return
	
	if event.is_action_pressed("cast"):
		on_cast_pressed()
	
	if event.is_action_pressed("element_1"):
		add_element(0)
	
	if event.is_action_pressed("element_2"):
		add_element(1)
	
	if event.is_action_pressed("element_3"):
		add_element(2)


func on_cast_pressed():
	var success: String = Bgm.check_accuracy(true)
	
	if Bgm.playing == false:
		Bgm.play_sample(container)
	
	if success == "missed":
		return
	
	Bus.player_cast.emit(container, success)
	
	cast_spell()


func add_element(element: int):
	var container_ui: ElementContainerUI = get_tree().get_first_node_in_group("element_container_ui")
	
	if container_ui == null:
		printerr(self, ": container_ui not found")
		return
	
	var success: String = Bgm.check_accuracy(true)
	
	if success == "missed":
		return
	
	if not Vars.last_activated_circle == null:
		Vars.last_activated_circle.change_texure(Vars.elements[element].texture)
	
	element_expiry()
	
	if container.size() > 2:
		container.push_front(element)
		container.remove_at(3)
	else:
		container.append(element)
	
	container_ui.update()


func cast_spell():
	Bgm.play_sample(container)
	
	if container == []:
		if not Vars.last_activated_circle == null:
			Vars.last_activated_circle.texture = EMPTY_CAST_SIGIL
		return
	
	if not Vars.last_activated_circle == null:
		Vars.last_activated_circle.texture = CAST_SIGIL
	
	var key: StringName = check_for_combo(container)
	
	if enough_dopamine(key) == false:
		create_projectile()
		remove_all_elements()
		return
	
	apply_combo_effect(key)
	
	if check_for_suppress(key) == true:
		remove_all_elements()
		return
	
	fire(key)



func fire(key):
	var delay:= 0.2
	var amount:= 1
	
	if not key == "":
		if "extra_amount" in SpellCombos.combos[key]:
			amount += SpellCombos.combos[key]["extra_amount"]
		
		if "delay" in SpellCombos.combos[key]:
			delay = SpellCombos.combos[key]["delay"]
	
	for index in amount:
		if not index == 0:
			await get_tree().create_timer(delay).timeout
		
		create_projectile(get_projectile_effect(key))
	
	remove_all_elements()


func apply_combo_effect(key: String):
	if key == "":
		return
	
	Bus.player_used_combo.emit(key)


func enough_dopamine(key: String):
	if key == "":
		return
	
	if not "mana_cost" in SpellCombos.combos[key]:
		return true
	
	var cost: float = SpellCombos.combos[key]["mana_cost"]
	
	if cost <= Vars.dopamine:
		Vars.dopamine -= cost
		return true
	
	Bus.not_enough_dopamine.emit()
	return false


func check_for_suppress(key: String):
	if key == "":
		return
	
	if "supress_attack" in SpellCombos.combos[key]:
		return true
	
	return false


func get_projectile_effect(key: String):
	if key == "":
		return ""
	
	var projectile_effect_path:= ""
	
	if "projectile_effect_path" in SpellCombos.combos[key]:
		projectile_effect_path = SpellCombos.combos[key]["projectile_effect_path"]
	
	return projectile_effect_path


#func get_projectile_stats(projectile_inst: Projectile):
	#var key: StringName = check_for_combo(container)
	#
	#if key == "":
		#return ""
	#
	#if "projectile_speed" in SpellCombos.combos[key]:
		#projectile_inst.projectile_speed = SpellCombos.combos[key]["projectile_speed"]


func remove_all_elements():
	var container_ui: ElementContainerUI = get_tree().get_first_node_in_group("element_container_ui")
	
	container.clear()
	container_ui.update()


func check_for_combo(elements: Array[int]):
	for key in SpellCombos.combos:
		if is_combo_match(elements, SpellCombos.combos[key]["combo"]):
			return key
	
	return ""


func is_combo_match(spell: Array, combo: Array) -> bool:
	return count_elements(spell) == count_elements(combo)


func count_elements(arr: Array) -> Dictionary:
	var counts := {}
	for e in arr:
		counts[e] = counts.get(e, 0) + 1
	return counts


func create_projectile(projectile_effect_path: String = ""):
	var projectile_inst: SpellProjectile = PROJECTILE.instantiate()
	var look_at_direction: Vector3 = Find.P().get_look_at_direction()
	
	projectile_inst.direction = look_at_direction.normalized()
	projectile_inst.color = determine_color()
	projectile_inst.damage = determine_damage()
	projectile_inst.origin_node = Find.P()
	projectile_inst.max_distance *= spell_range_mult
	projectile_inst.projectile_effect_path = projectile_effect_path
	
	for value in container:
		projectile_inst.elements.append(value)
	
	owner.get_parent().add_child(projectile_inst)
	
	projectile_inst.global_position = Find.P().camera.global_position


func element_expiry():
	var container_ui: ElementContainerUI = get_tree().get_first_node_in_group("element_container_ui")
	container_ui.element_expiry_timer.start(Bgm.rhythm_notifier.beat_length * element_expiry_time_mult)
	await container_ui.element_expiry_timer.timeout
	Vars.element_container.clear()
	container_ui.update()


func determine_damage():
	var player: Player = owner
	var damage:= 0.0
	var bonus_from_score: float = min(100.0, Vars.score / 20.0)
	
	damage += (
		(player.damage * Vars.element_container.size())
		+ 
		bonus_from_score
		)
	
	return damage * player.damage_mult


func determine_color():
	var color:= Color.WHITE
	
	for element in Vars.element_container:
		if not "id" in Vars.elements[element]:
			return
		
		if Vars.elements[element].id == "joy":
			color.b -= 0.3
		
		if Vars.elements[element].id == "sadness":
			color.r -= 0.15
			color.g -= 0.15
		
		if Vars.elements[element].id == "anger":
			color.b -= 0.15
			color.g -= 0.15
	
	return color
