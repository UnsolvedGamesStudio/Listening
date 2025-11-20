extends Projectile
class_name SpellProjectile
## Todo: change light color based on spell
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var elements: Array[int] = []


func enter():
	scale *= origin_node.scale
	animation_player.speed_scale /= origin_node.scale.x
