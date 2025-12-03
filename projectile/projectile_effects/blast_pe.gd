extends ProjectileEffect
class_name BlastPE
## Todo: Generate soot decals on the walls
## Todo: Rework animation
## Todo: Add tiny cooldown <- what did I even mean by this
@export var explosion_scene: PackedScene

var triggered:= false


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


func on_projectile_was_destroyed():
	if triggered == true:
		return
	
	triggered = true
	create_explosion(projectile.global_position)


func on_projectile_hit_body(hit_pos: Vector3, hit_normal: Vector3, body: Node):
	if triggered == true:
		return
	
	if body.owner is Enemy:
		return
	
	triggered = true
	
	var position:= hit_pos + hit_normal * 0.4
	create_explosion(position)


func on_hitbox_hit_body(hit_pos: Vector3, body: RigidBody3D):
	if triggered == true:
		return
	
	triggered = true
	
	var position = hit_pos.lerp(body.global_position, 0.5)
	create_explosion(position)
