extends Projectile
class_name EnemyProjectile
## Todo: change light color based on data
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var elements: Array[int] = []


func enter():
	scale *= origin_node.scale
	max_distance = 30.0
	

func on_hitbox_area_entered(area: Area3D):
	if not origin_node == null:
		if not "owner" in area:
			return
		
		if area.owner == origin_node:
			return
	
		if not area.owner is Enemy:
			return
	
	Bus.spell_landed.emit(elements)
	
	destroy()
