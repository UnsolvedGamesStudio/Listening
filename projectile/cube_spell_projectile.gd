extends SpellProjectile
class_name CubeSpellProjectile
## Todo: Make compatible bodies be blown away by explosions
@onready var kill_timer_2: Timer = %KillTimer2


func enter():
	scale *= origin_node.scale
	animation_player.speed_scale /= origin_node.scale.x
	apply_impulse(Vector3(0.0, 30.0, 0.0))


func in_process():
	if destroyed == true:
		return
	
	var damage_modifier:= linear_velocity.length() / 35
	speed += 3.0
	damage += damage_modifier
	
	if linear_velocity.x < 0.1 and linear_velocity.z < 0.1 and kill_timer_2.is_stopped() == true and get_colliding_bodies():
		freeze = true
		disable_damage()
		delayed_despawn()


func delayed_despawn():
	kill_timer_2.start(30.0)
	await kill_timer_2.timeout
	queue_free()


func disable_damage():
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)


func on_hitbox_area_entered(area: Area3D):
	disable_damage()
