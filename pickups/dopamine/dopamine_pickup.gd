extends RigidBody3D
class_name Dopamine
## Todo: Make pitch depend on last bounce height
## Todo: Make coming out of container more fun
@onready var animated_sprite_3d: AnimatedSprite3D = %AnimatedSprite3D
@onready var omni_light_3d: OmniLight3D = %OmniLight3D
@onready var pickup_sfx: AudioStreamPlayer = %PickupSFX
@onready var bounce_sfx: AudioStreamPlayer3D = %BounceSFX
@onready var magnet_range: Area3D = %MagnetRange
@onready var pickup_range: Area3D = %PickupRange
@onready var kill_timer: Timer = %KillTimer

@export var starting_move_rate:= 0.0035
var move_lerp_rate:= starting_move_rate

@export var worth:= 5.0

var bounce_counts:= 0
var magnet_triggered:= false
var rand_position_offset:= Vector3( randf_range(-0.5, 0.5), randf_range(-0.4, 0.4), randf_range(-0.5, 0.5) )


func _ready() -> void:
	await get_tree().create_timer(0.0).timeout
	omni_light_3d.light_color.h = randf()
	bounce_sfx.pitch_scale += randf_range(-0.1, 0.1)
	animated_sprite_3d.speed_scale *= randf_range(0.9, 1.1)
	global_position += rand_position_offset
	magnet_range.area_entered.connect(on_magnet_range_area_entered)
	pickup_range.area_entered.connect(on_pickup_range_area_entered)


func _physics_process(delta: float) -> void:
	rgb()
	play_bounce_sfx()
	move_towards_player()


func rgb():
	omni_light_3d.light_color.h += 0.0075


func play_bounce_sfx():
	if linear_velocity.y <= 0.1:
		return
	
	var colliders:= get_colliding_bodies()
	
	if colliders == []:
		return
	
	if bounce_sfx.playing == true:
		bounce_sfx.stop()
	
	bounce_counts += 1
	bounce_sfx.pitch_scale = min(2.0, bounce_sfx.pitch_scale + (bounce_counts / 100.0))
	bounce_sfx.play()


func move_towards_player():
	if magnet_triggered == false:
		return
	
	var player_pos:= Find.P().camera.global_position + (Vector3.DOWN / 1.05)
	
	if global_position == player_pos:
		return
	
	move_lerp_rate *= 1.1
	global_position = global_position.lerp(player_pos, move_lerp_rate)


func picked_up():
	pickup_sfx.reparent(get_parent())
	pickup_sfx.play()
	magnet_triggered = false
	magnet_range.get_child(0).set_deferred("disabled", true)
	pickup_range.get_child(0).set_deferred("disabled", true)
	Vars.dopamine += worth
	queue_free()


func on_magnet_range_area_entered(area: Area3D):
	if not area.is_in_group("player_collision"):
		return
	
	magnet_triggered = true


func on_pickup_range_area_entered(area: Area3D):
	if not area.is_in_group("player_collision"):
		return
	
	if magnet_triggered == true:
		kill_timer.start(0.2)
		await kill_timer.timeout
	
	picked_up()
