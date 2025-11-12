extends Projectile
class_name SpellProjectile
## Todo: change light color based on spell
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var elements: Array[int] = []


func enter():
	scale *= origin_node.scale
	animation_player.speed_scale /= origin_node.scale.x


func on_hitbox_area_entered(area: Area3D):
	if not origin_node == null:
		if not "owner" in area:
			return
		
		if area.owner == origin_node:
			return
	
		if not area.owner is Enemy:
			return
	
	hit_enemy.emit(area.owner)
	Bus.spell_landed.emit(elements)
	
	if not sfx == null:
		sfx.play()
	
	destroy()
