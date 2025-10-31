extends EnemyBehavior
class_name GetHurtEB

const DAMAGE_POPUP = preload("uid://caxugm1j30feu")

var hurtbox: Area3D
var health_bar: ProgressBar

var max_hp:= 100.0:
	set(value):
		max_hp = clampf(value, 1.0, 99999.9)

var hp:= max_hp:
	set(value):
		hp = clampf(value, 0.0, max_hp)


func enter() -> void:
	set_stats()
	
	if "enemy_collision" in O:
		hurtbox = O.enemy_collision
	
	if "health_bar" in O:
		health_bar = O.health_bar
	
	if health_bar == null:
		printerr(self, " of ", O, ": health_bar not found")
	
	if hurtbox == null:
		printerr(self, " of ", O, ": hurtbox (enemy_collision) not found")
	
	else:
		hurtbox.area_entered.connect(on_hurtbox_area_entered)


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


func take_damage(amount: float):
	hp -= amount
	
	if "hurt" in O.idle_anim.get_animation_list():
		O.idle_anim.play("hurt")
	
	generate_text(amount)
	
	if hp <= 0:
		die()


func die():
	for behavior in get_parent().get_children():
		if "enabled" in behavior:
			behavior.enabled = false
	
	if hurtbox == null:
		printerr(self, " of ", O, ": hurtbox not found")
	else:
		hurtbox.queue_free()
	
	Vars.living_enemies.erase(O)
	
	
	if "die" in O.idle_anim.get_animation_list():
		O.idle_anim.play("die")
	
	if O.idle_anim.is_playing():
		await O.idle_anim.animation_finished
	
	O.queue_free()


func generate_text(amount: float):
	var player: Player = get_tree().get_first_node_in_group("player")
	var text_inst: Node3D = DAMAGE_POPUP.instantiate()
	var rand_vector3:= Vector3( randf_range(-0.5, 0.1), randf_range(-0.5, 0.5), randf_range(-0.5, 0.5) )
	add_child(text_inst)
	text_inst.global_position = O.sprite_3d.global_position + rand_vector3
	text_inst.label.text = str( int(amount) )


func on_hurtbox_area_entered(area: Area3D):
	if not "damage" in area.owner:
		return
	
	take_damage(area.owner.damage)
