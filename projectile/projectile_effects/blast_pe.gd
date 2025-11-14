extends ProjectileEffect
class_name BlastPE
## Todo: generate soot decals on the walls
## Todo: rework animation
@export var explosion_scene: PackedScene


func enter():
	if explosion_scene == null:
		printerr(self, ": explosion_scene not found, freeing self")
		queue_free()
		return


func create_explosion(pos):
	var explosion_inst: Node3D = explosion_scene.instantiate()
	
	Find.layout().add_child(explosion_inst)
	explosion_inst.global_position = pos


func on_projectile_hit_terrain(hit_pos: Vector3, hit_normal: Vector3):
	## Todo: get the proper normals
	#var pos:= hit_pos + hit_normal * 0.25
	var pos:= projectile.global_position
	create_explosion(pos)


func on_projectile_hit_entity(entity: Node3D):
	create_explosion(projectile.global_position)
