extends Projectile
class_name SpellProjectile
## Todo: change light color based on spell
## Todo: clean up old area related behavior
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var elements: Array[int] = []


func enter():
	scale *= origin_node.scale
	animation_player.speed_scale /= origin_node.scale.x


func collided_with_enemy(enemy: Enemy):
	if "behaviors_container" in enemy:
		for behavior in enemy.behaviors_container.get_children():
			if not behavior is GetHurtEB:
				return
			
			behavior.hit_by_projectile(self)


#func on_collided(collider: Node3D):
	#if collider.owner == origin_node:
		#return
	#
	#if not collider.is_in_group("enemy_collision"):
		#return
	#
	#print(collider)
	#
	#if not sfx == null:
		#sfx.play()
