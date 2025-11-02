extends EnemyBehavior
class_name LoseAlphaFromElementEB

@export var element:= 0
@export var mesh: MeshInstance3D
@export var amount_to_remove:= 0.16

var hurtbox: Area3D


func enter() -> void:
	if "enemy_collision" in O:
		hurtbox = O.enemy_collision
	
	if hurtbox == null:
		printerr(self, " of ", O, ": hurtbox (enemy_collision) not found")
	
	else:
		hurtbox.area_entered.connect(on_hurtbox_area_entered)


func on_hurtbox_area_entered(area: Area3D):
	if not area.owner is SpellProjectile:
		return
	
	var material: Material = mesh.get_active_material(0)
	
	for value: int in area.owner.elements:
		
		if value == 0:
			
			material.albedo_color.a -= amount_to_remove
		
			if material.albedo_color.a <= 0.0:
				O.queue_free()
