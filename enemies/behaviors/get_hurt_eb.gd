extends EnemyBehavior
class_name GetHurtEB
## Todo: On hit animation
const DAMAGE_POPUP = preload("uid://caxugm1j30feu")

@onready var die_sfx: AudioStreamPlayer3D = %DieSFX

var hurtbox
var health_bar: ProgressBar

var max_hp:= 100.0:
	set(value):
		max_hp = clampf(value, 1.0, 99999.9)

var hp:= max_hp:
	set(value):
		hp = clampf(value, 0.0, max_hp)


func enter() -> void:
	set_stats()
	O.hit_by_player_damage.connect(on_hit_by_player_damage)


func _physics_process(delta: float) -> void:
	update_value()


func update_value():
	health_bar = %HealthBar
	if health_bar == null:
		printerr(self, ": health_bar not found")
		return
	
	health_bar.max_value = max_hp / 100
	health_bar.value = lerp(health_bar.value, hp / 100, 0.33)
	health_bar.modulate.r = health_bar.max_value - health_bar.value
	health_bar.modulate.g = health_bar.value


func set_stats():
	var data: EnemyResource = O.data
	
	if data == null:
		printerr(self, " of ", O, ": data not found")
		return
	
	max_hp = data.max_hp
	hp = max_hp


func take_damage(amount: float, with_elements: bool = false, elements: Array[int] = []):
	if "hurt" in O.idle_anim.get_animation_list():
		O.idle_anim.play("hurt")
	
	var final_damage:= amount
	var weakness_mult: float = calculate_weaknesses(elements)
	final_damage *= weakness_mult
	
	lose_hp(final_damage)
	generate_text(final_damage, weakness_mult)
	O.took_damage.emit(final_damage)


func calculate_weaknesses(elements: Array[int] = []):
	var total_mult:= 1.0
	
	if 0 in elements:
		total_mult = mult_handle_negative(O.data.joy_damage_mult, total_mult)
	
	if 1 in elements:
		total_mult = mult_handle_negative(O.data.sad_damage_mult, total_mult)
	
	if 2 in elements:
		total_mult = mult_handle_negative(O.data.anger_damage_mult, total_mult)
	
	return total_mult


func mult_handle_negative(mult: float, total_mult: float):
	if mult == 1.0:
		return total_mult
	
	if mult > 1.0:
		total_mult += mult - 1
		return total_mult
	
	if mult < 1.0:
		total_mult -= mult
		return total_mult


func lose_hp(amount: float):
	hp -= amount
	
	if hp <= 0:
		die()


func die():
	for behavior in get_parent().get_children():
		if "enabled" in behavior:
			behavior.enabled = false
	
	enabled = false
	
	if O in Vars.living_enemies:
		Vars.living_enemies.erase(O)
	
	die_sfx.reparent(O.get_parent())
	die_sfx.play()
	
	if "die" in O.idle_anim.get_animation_list():
		O.idle_anim.play("die")
	else:
		O.queue_free()
	
	if O.idle_anim.is_playing():
		await O.idle_anim.animation_finished
	
	O.drop_loot()
	O.queue_free()


func generate_text(amount: float, mult: float):
	var player: Player = get_tree().get_first_node_in_group("player")
	var text_inst: Node3D = DAMAGE_POPUP.instantiate()
	var rand_vector3:= Vector3( randf_range(-0.5, 0.1), randf_range(-0.5, 0.5), randf_range(-0.5, 0.5) )
	
	add_child(text_inst)
	text_inst.global_position = O.sprite_3d.global_position + rand_vector3
	text_inst.scale *= clampf(mult, 0.8, 3.0)
	
	var label: Label = text_inst.label
	var neutral_color:= Color.BLACK
	var strong_color:= Color.DEEP_PINK
	var weak_color:= Color.ROYAL_BLUE
	
	label.text = str( int(amount) )
	
	if mult == 1.0:
		label.add_theme_color_override("font_color", neutral_color)
	
	if mult > 1.0:
		label.add_theme_color_override("font_color", strong_color)
	
	if mult < 1.0:
		label.add_theme_color_override("font_color", weak_color)


func on_hit_by_player_damage(source: Node):
	if enabled == false:
		return
	
	if not "damage" in source:
		return
	
	if "elements" in source:
		take_damage(source.damage, true, source.elements)
		return
	
	take_damage(source.damage)
