extends Projectile
class_name SpellProjectile
## Todo: change light color based on spell
@onready var collision_size: CollisionShape3D = %CollisionSize
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var spawn_sfx: AudioStreamPlayer3D = %SpawnSFX
@onready var passive_sfx: AudioStreamPlayer3D = %PassiveSFX
@onready var bounce_sfx: AudioStreamPlayer3D = %BounceSFX
@onready var destroy_sfx: AudioStreamPlayer3D = %DestroySFX
@onready var expire_sfx: AudioStreamPlayer3D = %ExpireSFX

var elements: Array[int] = []


func enter():
	adapt_size()
	init_sfx()
	
	if not spawn_sfx.stream == null:
		spawn_sfx.play()
	
	if not passive_sfx.stream == null:
		passive_sfx.play()
	
	sub_enter()


func adapt_size():
	var scale_to_copy:= origin_node.scale
	if scale_to_copy >= Vector3(1.0, 1.0, 1.0):
		return
	
	sprite_3d.scale = scale_to_copy
	collision_size.scale = scale_to_copy
	hitbox.scale = hitbox.scale.lerp(scale_to_copy, 0.2)


func init_sfx():
	if data == null:
		return
	
	set_fx(spawn_sfx, data.spawn_sfx)
	set_fx(passive_sfx, data.passive_sfx)
	set_fx(bounce_sfx, data.bounce_sfx)
	set_fx(destroy_sfx, data.destroy_sfx)
	set_fx(expire_sfx, data.expire_sfx)


func set_fx(stream_player: AudioStreamPlayer3D, sfx_path: String):
	var stream: AudioStream = load_sfx(sfx_path)
	var pitch_range:= data.randomize_pitch_range / 2
	
	if stream == null:
		return
	
	stream_player.stream = stream
	stream_player.pitch_scale += randf_range(-pitch_range, pitch_range)


func sub_enter():
	pass


func load_sfx(path):
	if path == "":
		return
	
	if not ResourceLoader.exists(path):
		printerr(self, ": projectile sfx has invalid path of '", path, "'")
		return
	
	return load(path)


func stop_passive_sfx():
	if not passive_sfx.stream == null:
		passive_sfx.stop()


func on_bounce():
	if bounce_sfx.playing == true:
		return
	
	bounce_sfx.play()


func on_destroyed():
	destroy_sfx.play()
	stop_passive_sfx()


func on_expired():
	expire_sfx.play()
	stop_passive_sfx()
