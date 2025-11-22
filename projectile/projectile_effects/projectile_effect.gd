extends Node
class_name ProjectileEffect

var projectile: Projectile


func _ready() -> void:
	if projectile == null:
		printerr(self, ": parent projectile not found, freeing self")
		queue_free()
		return
	
	projectile.hit_body.connect(on_projectile_hit_body)
	projectile.hitbox_hit_body.connect(on_hitbox_hit_body)
	projectile.was_destroyed.connect(on_projectile_was_destroyed)
	projectile.tree_exited.connect(on_projectile_tree_exited)
	
	enter()


func enter():
	pass


func on_projectile_hit_body(hit_pos: Vector3, hit_normal: Vector3, body):
	pass


func on_hitbox_hit_body(hit_pos: Vector3, body: RigidBody3D):
	pass


func on_projectile_was_destroyed():
	pass


func on_projectile_tree_exited():
	pass
