extends Node
class_name ProjectileEffect

var projectile: Projectile


func _ready() -> void:
	if projectile == null:
		printerr(self, ": parent projectile not found, freeing self")
		queue_free()
		return
	
	projectile.hit_terrain.connect(on_projectile_hit_terrain)
	
	if projectile.has_signal("hit_enemy"):
		projectile.hit_enemy.connect(on_projectile_hit_entity)
	
	enter()


func enter():
	pass


func on_projectile_hit_terrain(hit_pos: Vector3, hit_normal: Vector3):
	pass


func on_projectile_hit_entity(entity: Node3D):
	pass
