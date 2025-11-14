extends Node3D
class_name Dopamine
## Todo: maybe make the dopamine into a gauge, making it more unique as a currency, could also be used as a charge
@onready var animated_sprite_3d: AnimatedSprite3D = %AnimatedSprite3D
@onready var area_3d: Area3D = %Area3D
@onready var sfx: AudioStreamPlayer = %SFX

@export var worth:= 1.0

var rand_position_offset:= Vector3( randf_range(-0.5, 0.5), randf_range(-0.4, 0.25), randf_range(-0.5, 0.5) )


func _ready() -> void:
	await get_tree().create_timer(0.0).timeout
	animated_sprite_3d.speed_scale *= randf_range(0.9, 1.1)
	global_position += rand_position_offset
	area_3d.area_entered.connect(on_area_3d_area_entered)


func go_to_player():
	area_3d.get_child(0).set_deferred("disabled", true)
	
	if not find_child("Particles") == null:
		find_child("Particles").emitting = false
	
	var player: Player = get_tree().get_first_node_in_group("player")
	var tween:= create_tween()
	var tween_length_mult:= 2.0
	var camera_pos:= player.camera.global_position
	var target_pos:= Vector3(camera_pos.x, camera_pos.y * 0.8, camera_pos.z)
	
	tween.set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(animated_sprite_3d, "global_position", target_pos, Bgm.rhythm_notifier.beat_length * tween_length_mult)
	tween.parallel().tween_property(self, "scale", Vector3(0.6, 0.6, 0.6), Bgm.rhythm_notifier.beat_length * tween_length_mult)
	await tween.finished
	picked_up()


func picked_up():
	sfx.reparent(get_parent())
	sfx.play()
	Vars.dopamine += worth
	queue_free()


func on_area_3d_area_entered(area: Area3D):
	if not area.is_in_group("player_collision"):
		return
	
	go_to_player()
