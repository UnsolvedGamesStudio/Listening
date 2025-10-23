extends EnemyBehavior
class_name GetHurtEB

var enabled:= true

@export var max_hp:= 100.0:
	set(value):
		max_hp = clampf(value, 1.0, 99999.9)

@export var hp:= max_hp:
	set(value):
		hp = clampf(value, 0.0, max_hp)

var hurtbox: Area3D
var health_bar: ProgressBar


func _ready() -> void:
	if "enemy_collision" in O:
		hurtbox = O.enemy_collision
	
	if "health_bar" in O:
		health_bar = O.health_bar
	
	if hurtbox == null:
		printerr(self, " of ", O, ": hurtbox not found")
	else:
		hurtbox.area_entered.connect(on_hurtbox_area_entered)
	
	update_health_bar_value()


func take_damage(amount: float):
	hp -= amount
	update_health_bar_value()
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
	
	O.idle_anim.play("die")


func update_health_bar_value():
	if health_bar == null:
		printerr(self, " of ", O, ": health_bar not found")
		return
	
	health_bar.value = hp / 100
	health_bar.modulate.r = (health_bar.max_value - health_bar.value)
	health_bar.modulate.g = health_bar.value


func on_hurtbox_area_entered(area: Area3D):
	if not "damage" in area.owner:
		return
	
	take_damage(area.owner.damage)
