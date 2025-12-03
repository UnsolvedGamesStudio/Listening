extends Critter

@onready var hurtbox: Area3D = %Hurtbox
@onready var wall_detect: Area3D = %WallDetect
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var ambient_sfx: AudioStreamPlayer3D = %AmbientSFX
@onready var die_sfx: AudioStreamPlayer3D = %DieSFX


func on_die():
	var rand_a:= randf()
	var rand_b:= randf()

	var z_rotation:= 3
	var torque_impulse:= Vector3(rand_a / 2.0, rand_b, z_rotation / 2.0)
	
	var y_jump:= 4.0 * randf_range(0.5, 1.2)
	var impulse:= Vector3(rand_a, y_jump, rand_b)
	
	apply_impulse(impulse)
	apply_torque_impulse(torque_impulse)
	
	ambient_sfx.stop()
	die_sfx.play()
	destroy()
