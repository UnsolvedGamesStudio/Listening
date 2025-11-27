extends SpellProjectile
class_name CubeSpellProjectile
## Todo: Make compatible bodies be blown away by explosions
## Todo: Make the curve feel more natural
@onready var kill_timer_2: Timer = %KillTimer2

var breaks_walls:= false


func sub_enter():
	scale *= origin_node.scale
	animation_player.speed_scale /= origin_node.scale.x
	apply_impulse(Vector3(0.0, 35.0, 0.0))


func in_process():
	if destroyed == true:
		return
	
	set_can_break()
	
	var damage_modifier:= linear_velocity.length() / 35
	speed += 3.0
	damage += damage_modifier
	
	if linear_velocity.x < 0.1 and linear_velocity.z < 0.1 and kill_timer_2.is_stopped() == true and get_colliding_bodies():
		freeze = true
		disable_damage()
		delayed_despawn()


func set_can_break():
	var horizontal: float = abs(Vector3(linear_velocity.x, 0.0, linear_velocity.z).length())
	if horizontal > 1.0:
		breaks_walls = true
	else:
		breaks_walls = false


func delayed_despawn():
	kill_timer_2.start(30.0)
	await kill_timer_2.timeout
	queue_free()


func disable_damage():
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)


func on_hitbox_area_entered(area: Area3D):
	disable_damage()
