extends EnemyBehavior
## Todo: if a wax mound is in range, make it eat it to regenerate
## Todo: make wane drop wax
@export var get_hurt_eb: GetHurtEB
@export var light: OmniLight3D
@export var self_damage_amount:= 25.0

var original_scale:= Vector3.ONE
var original_energy:= 0.0


func enter():
	original_scale = O.to_animate.scale
	original_energy = light.light_energy
	O.took_damage.connect(on_took_damage)
	O.used_melee.connect(on_used_melee)


func self_damage():
	if enabled == false:
		return
	
	if get_hurt_eb == null:
		push_error(self, " of ", O , ": get_hurt_eb_not_found")
		return
	
	get_hurt_eb.lose_hp(self_damage_amount)


func shrink():
	if enabled == false:
		return
	
	if get_hurt_eb == null:
		push_error(self, " of ", O , ": get_hurt_eb_not_found")
		return
	
	if not "to_animate" in O:
		return
	
	tween_values()


func tween_values():
	var tween:= create_tween()
	var shrink_amount:= original_scale.y * (get_hurt_eb.hp / get_hurt_eb.max_hp)
	var dim_amount:= original_energy * (get_hurt_eb.hp / get_hurt_eb.max_hp)
	
	tween.parallel().tween_property(O.to_animate, "scale:y", shrink_amount, 0.25)
	tween.parallel().tween_property(light, "light_energy", dim_amount, 0.25)
	
	if O.find_child("HealthBar3D") == null:
		return
	
	var hp_bar_move_amount: float = O.find_child("HealthBar3D").position.y - (O.sprite_3d.position.y + O.sprite_3d.texture.get_size().y) / 500
	
	tween.tween_property(O.find_child("HealthBar3D"), "position:y", hp_bar_move_amount, 0.25)


func on_took_damage(_amount: float):
	shrink()


func on_used_melee():
	shrink()
	self_damage()
