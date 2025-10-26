extends EnemyBehavior
class_name GetHurtEB

var enabled:= true

var max_hp:= 100.0:
	set(value):
		max_hp = clampf(value, 1.0, 99999.9)

var hp:= max_hp:
	set(value):
		hp = clampf(value, 0.0, max_hp)

var hurtbox: Area3D
var health_bar: ProgressBar


func _ready() -> void:
	set_stats()
	
	if "enemy_collision" in O:
		hurtbox = O.enemy_collision
	
	if "health_bar" in O:
		health_bar = O.health_bar
	
	if hurtbox == null:
		printerr(self, " of ", O, ": hurtbox not found")
	else:
		hurtbox.area_entered.connect(on_hurtbox_area_entered)


func _physics_process(delta: float) -> void:
	update_value()


func update_value():
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
	O.idle_anim.play("hurt")
	
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
	O.idle_anim.play("die")


func on_hurtbox_area_entered(area: Area3D):
	if not "damage" in area.owner:
		return
	
	take_damage(area.owner.damage)
