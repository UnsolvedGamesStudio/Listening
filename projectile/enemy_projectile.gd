extends Projectile
class_name EnemyProjectile
## Todo: Change light color based on data
## Todo: Configure friendly fire
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var elements: Array[int] = []


func enter():
	max_distance = 30.0


func on_hitbox_area_entered(area: Area3D):
	if not origin_node == null:
		if area.owner == origin_node:
			return
	
	if not area.owner.has_method("take_damage"):
		return
	
	area.owner.take_damage(damage)
	
	destroy()
