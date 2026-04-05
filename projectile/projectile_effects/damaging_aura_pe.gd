extends ProjectileEffect
class_name DamagingAuraPE

@onready var damage_cooldown: Timer = %DamageCooldown
@onready var hitbox: Area3D = %Hitbox
@onready var appear: AnimationPlayer = %Appear

@export var damage:= 5.0
@export var hide_projectile:= false


func enter():
	if projectile.origin_node.scale.y < 1.0:
		appear.speed_scale /= (projectile.origin_node.scale.y * 2.0)
	
	projectile.disable_hitbox()
	
	if hide_projectile:
		projectile.sprite_3d.hide()
	
	damage_cooldown.timeout.connect(on_damage_cooldown_timeout)


func on_projectile_was_destroyed():
	var tween:= create_tween()
	tween.tween_property(self, "scale", Vector3(0.01, 0.01, 0.01), 1.0)
	tween.tween_callback(queue_free)


func on_damage_cooldown_timeout():
	for body in hitbox.get_overlapping_bodies():
		if body.owner.has_signal("hit_by_player_damage"):
			body.owner.hit_by_player_damage.emit(self)
