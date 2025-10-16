extends CharacterBody3D
class_name Projectile

@onready var hitbox: Area3D = $Hitbox
@onready var flying_particles: GPUParticles3D = $FlyingParticles
@onready var hit_particles: GPUParticles3D = $HitParticles
@onready var kill_timer: Timer = $KillTimer
@onready var sprite_3d: Sprite3D = $Sprite3D

var target_point:= Vector3.ZERO
var speed:= 60.0
var direction:= Vector3.ZERO
var player: Player
var look_at_direction:= Vector3.ZERO


func _ready() -> void:
	hitbox.area_entered.connect(on_hitbox_area_entered)


func _physics_process(delta: float) -> void:
	var cam_pos = player.camera.global_position
	
	look_at_direction = Vector3(cam_pos.x + 0.001, cam_pos.y + 0.001, cam_pos.z + 0.001)
	direction = global_position.direction_to(target_point)
	
	velocity += direction * speed * delta
	look_at(look_at_direction)
	
	move_and_slide()


func on_hitbox_area_entered(area: Area3D):
	destroy()


func destroy():
	sprite_3d.hide()
	set_deferred("hitbox.monitorable", false)
	set_deferred("hitbox.monitoring", false)
	kill_timer.start()
	await kill_timer.timeout
	queue_free()
