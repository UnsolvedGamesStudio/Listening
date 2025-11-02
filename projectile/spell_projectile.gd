extends Projectile
class_name SpellProjectile


var elements: Array[int] = []

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
