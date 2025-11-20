extends EnemyBehavior
class_name LoseAlphaFromElementEB

@export var element:= 0
@export var mesh: MeshInstance3D
@export var amount_to_remove:= 0.16

var hurtbox: Area3D


func enter() -> void:
	O.hit_by_projectile.connect(on_hit_by_projectile)


func on_hit_by_projectile(projectile: Projectile):
	if not "elements" in projectile:
		return
	
	var material: Material = mesh.get_active_material(0)
	
	for value: int in projectile.elements:
		
		if value == element:
			
			material.albedo_color.a -= amount_to_remove
		
			if material.albedo_color.a <= 0.0:
				O.queue_free()
