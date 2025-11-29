extends ProjectileEffect
class_name BlastPE
## Todo: Generate soot decals on the walls
## Todo: Rework animation
## Todo: Add tiny cooldown
@export var explosion_scene: PackedScene


func enter():
	if explosion_scene == null:
		printerr(self, ": explosion_scene not found, freeing self")
		queue_free()
		return


func create_explosion(position):
	var explosion_inst: Node3D = explosion_scene.instantiate()
	
	Find.layout().add_child(explosion_inst)
	explosion_inst.scale = Find.P().scale
	explosion_inst.global_position = position


func on_projectile_hit_body(hit_pos: Vector3, hit_normal: Vector3, body: Node):
	if body.owner is Enemy:
		return
	
	var position:= hit_pos + hit_normal * 0.4
	create_explosion(position)


func on_hitbox_hit_body(hit_pos: Vector3, body: RigidBody3D):
	var position = hit_pos.lerp(body.global_position, 0.5)
	create_explosion(position)
