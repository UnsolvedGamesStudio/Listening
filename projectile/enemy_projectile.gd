extends Projectile
class_name EnemyProjectile
## Todo: change light color based on data
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var elements: Array[int] = []


func enter():
	max_distance = 30.0


func collided_with_player():
	Find.P().take_damage(damage, origin_node)


func collided_with_shield(shield: ShellObject):
	shield.take_damage(damage)


#func on_hitbox_area_entered(area: Area3D):
	#if not origin_node == null:
		#if area.owner == origin_node:
			#return
	#
	#if area.owner is ShellObject:
		#destroy()
		#return
#
	#Bus.spell_landed.emit(elements)
	#
	#destroy()
