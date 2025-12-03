extends CritterBehavior

@export var hp:= 10.0


func level_ready():
	if "hurtbox" in O:
		O.hurtbox.area_entered.connect(on_hurtbox_area_entered)


func take_damage(amount: float):
	hp -= amount
	
	if hp <= 0.0:
		O.die()


func on_hurtbox_area_entered(area: Area3D):
	if O.dead == true:
		return
	
	if area.owner == O:
		return
	
	if not "damage" in area.owner:
		return
	
	take_damage(area.owner.damage)
