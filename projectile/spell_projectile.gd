extends Projectile
class_name SpellProjectile
## Todo: change light color based on spell
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var spawn_sfx: AudioStreamPlayer3D = %SpawnSFX
@onready var passive_sfx: AudioStreamPlayer3D = %PassiveSFX
@onready var bounce_sfx: AudioStreamPlayer3D = %BounceSFX
@onready var destroy_sfx: AudioStreamPlayer3D = %DestroySFX
@onready var expire_sfx: AudioStreamPlayer3D = %ExpireSFX

var elements: Array[int] = []


func enter():
	if not data == null:
		init_sfx(spawn_sfx, data.spawn_sfx)
		init_sfx(passive_sfx, data.passive_sfx)
		init_sfx(bounce_sfx, data.bounce_sfx)
		init_sfx(destroy_sfx, data.destroy_sfx)
		init_sfx(expire_sfx, data.expire_sfx)
	
	scale *= origin_node.scale
	animation_player.speed_scale /= origin_node.scale.x
	
	if not spawn_sfx.stream == null:
		spawn_sfx.play()
	
	if not passive_sfx.stream == null:
		passive_sfx.play()
	
	sub_enter()


func init_sfx(stream_player: AudioStreamPlayer3D, sfx_path: String):
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
	
	if not FileAccess.file_exists(path):
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
