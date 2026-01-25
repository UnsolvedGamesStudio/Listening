extends Interactable
class_name DopamineReplenisher

@onready var animated_sprite_3d: AnimatedSprite3D = %AnimatedSprite3D
@onready var interaction_area: Area3D = %InteractionArea
@onready var audio_stream_player_3d: AudioStreamPlayer3D = %AudioStreamPlayer3D

var original_scale:= Vector3.ONE
var sprite_tween: Tween
var base_sprite_scale:= Vector3.ONE


func _ready() -> void:
	original_scale = scale
	base_sprite_scale = animated_sprite_3d.scale


func _physics_process(delta: float) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		return
	
	if player.los.get_collider() == interaction_area and global_position.distance_to(player.global_position) < Vars.interact_range:
		looked_at_by_player(true)
	else:
		looked_at_by_player(false)


func activate():
	max_out_dopamine()
	animate_sprite()
	play_sfx()


func animate_sprite():
	if sprite_tween and sprite_tween.is_running():
		animated_sprite_3d.scale = base_sprite_scale
		sprite_tween.kill()
	
	sprite_tween = create_tween()
	
	var duration:= 0.3
	var start_scale:= animated_sprite_3d.scale
	var target_scale:= animated_sprite_3d.scale * 1.2
	
	sprite_tween.tween_property(animated_sprite_3d, "scale", target_scale, duration * 0.5)\
		.from(start_scale)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	sprite_tween.tween_property(animated_sprite_3d, "scale", start_scale, duration * 0.5)\
		.from(target_scale)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)


func play_sfx():
	audio_stream_player_3d.pitch_scale = randf_range(1.25, 1.5)
	audio_stream_player_3d.play()


func max_out_dopamine():
	Vars.dopamine = Vars.max_dopamine


func looked_at_by_player(on: bool):
	if on:
		if scale == original_scale * 1.1:
			return
		
		scale = original_scale * 1.1
	else:
		if scale == original_scale:
			return
		
		scale = original_scale
