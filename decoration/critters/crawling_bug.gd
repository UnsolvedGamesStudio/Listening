extends Critter

@onready var animated_sprite_3d: AnimatedSprite3D = %AnimatedSprite3D
@onready var wall_detect: Area3D = %WallDetect
@onready var hurtbox: Area3D = %Hurtbox
@onready var poof_particles: GPUParticles3D = $PoofParticles
@onready var walk_sfx: AudioStreamPlayer3D = %WalkSFX
@onready var die_sfx: AudioStreamPlayer3D = %DieSFX


func enter() -> void:
	var rand_scale:= randf_range(0.6, 1.3)
	scale = Vector3(rand_scale, rand_scale, rand_scale)
	animated_sprite_3d.speed_scale *= randf_range(0.75, 1.25)


func level_ready():
	global_position.y += 3.95


func on_die():
	dead = true
	animated_sprite_3d.stop()
	walk_sfx.stop()
	die_sfx.play()
	
	gravity_scale = 1.0
	
	await get_tree().create_timer(1.0).timeout
	
	animated_sprite_3d.hide()
	poof_particles.emitting = true
	await poof_particles.finished
	destroy(0.0)
