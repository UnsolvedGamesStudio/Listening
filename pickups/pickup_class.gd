extends Node3D
class_name Pickup
## Todo: try to make the highlight the interact's responsibility again
## Todo: add a view of what object is on the player's tile
## Todo: make an "interactable" class higher than this one
@onready var sprite_3d: Sprite3D = %Sprite3D
@onready var area_3d: Area3D = %Area3D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@export var activate_on_interact:= true
@export var activate_on_contact:= true
@export var goes_towards_player:= true
@export var tween_length_mult:= 0.45
@export var vanishes:= false
@export var free_immediately:= false
@export var animate_every_x_beat:= 4
@export var interacted_color:= Color(0.0, 0.659, 0.593, 1.0)

@export var save_id: String = ""

@export var starting_move_rate:= 0.0035
var move_lerp_rate:= starting_move_rate

var activated:= false
var current_anim_rate:= animate_every_x_beat
var moving_to_player:= false



func _ready() -> void:
	enter()
	area_3d.area_entered.connect(on_area_3d_area_entered)
	Bus.beat.connect(on_beat)
	animation_player.speed_scale = Bgm.beat_timer.beat_length * 4


func _physics_process(delta: float) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		return
	
	move_towards_player()
	
	if player.los.get_collider() == area_3d and global_position.distance_to(player.global_position) < Vars.interact_range:
		looked_at_by_player(true)
	else:
		looked_at_by_player(false)


func enter():
	pass


func destroy():
	queue_free()


func on_beat(beat_count: int):
	if beat_count % current_anim_rate == 0:
		animation_player.play("on_beat")


func looked_at_by_player(on: bool):
	if on == true:
		sprite_3d.modulate = interacted_color
		animation_player.speed_scale = Bgm.beat_timer.beat_length * 8
		
		if not current_anim_rate < 2:
			current_anim_rate /= 2
	
	else:
		sprite_3d.modulate = Color(1.0, 1.0, 1.0, 1.0)
		animation_player.speed_scale = Bgm.beat_timer.beat_length * 4
		
		current_anim_rate = animate_every_x_beat


func activate():
	activated = true
	await on_activated()
	
	if free_immediately == true:
		destroy()
	
	if vanishes == true:
		vanish()
	
	if goes_towards_player == true:
		area_3d.set_deferred("monitoring", false)
		area_3d.set_deferred("monitorable", false)
		moving_to_player = true
		return
	
	if goes_towards_player == false and vanishes == false:
		destroy()


func move_towards_player():
	if moving_to_player == false:
		return
	
	var player_pos:= Find.P().camera.global_position + (Vector3.DOWN / 1.05)
	
	move_lerp_rate *= 1.15
	global_position = global_position.lerp(player_pos, move_lerp_rate)
	sprite_3d.position = sprite_3d.position.lerp(Vector3.ZERO, move_lerp_rate)
	
	if global_position.distance_to(player_pos) <= 0.1:
		destroy()


#func go_to_player():
	#area_3d.get_child(0).set_deferred("disabled", true)
	#animation_player.stop()
	#
	#if not find_child("Particles") == null:
		#find_child("Particles").emitting = false
	#
	#var player: Player = get_tree().get_first_node_in_group("player")
	#var tween:= create_tween()
	#var camera_pos:= player.camera.global_position
	#var target_pos:= Vector3(camera_pos.x, camera_pos.y * 0.8, camera_pos.z)
	#
	#tween.parallel().tween_property(sprite_3d, "global_position", target_pos, Bgm.beat_timer.beat_length * tween_length_mult)
	#tween.parallel().tween_property(self, "scale", Vector3(0.6, 0.6, 0.6), Bgm.beat_timer.beat_length * tween_length_mult)
	#tween.tween_callback(queue_free)


func vanish():
	var tween:= create_tween()
	
	tween.tween_property(sprite_3d, "modulate:a", 0.0,  Bgm.beat_timer.beat_length * tween_length_mult)
	tween.tween_callback(destroy)


func on_activated():
	pass


func on_area_3d_area_entered(area: Area3D):
	if activate_on_contact == false:
		return
	
	if not area.is_in_group("player_collision"):
		return
	
	activate()
