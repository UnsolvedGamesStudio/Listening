extends CharacterBody3D
class_name Projectile

@onready var hitbox: Area3D = $Hitbox
@onready var flying_particles: GPUParticles3D = $FlyingParticles
@onready var kill_timer: Timer = $KillTimer
@onready var sprite_3d: Sprite3D = $Sprite3D

var origin_node: Node3D
var target_point:= Vector3.ZERO
var direction:= Vector3.ZERO
var player: Player
var color:= Color.WHITE

var speed:= 60.0
var damage:= 50.0


func _ready() -> void:
	hitbox.area_entered.connect(on_hitbox_area_entered)
	sprite_3d.modulate = color


func _physics_process(delta: float) -> void:
	direction = global_position.direction_to(target_point)
	velocity += direction * speed * delta
	
	move_and_slide()


func on_hitbox_area_entered(area: Area3D):
	if not origin_node == null:
		if not "owner" in area:
			return
	
		if area.owner == origin_node:
			return
	destroy()


func destroy():
	#sprite_3d.hide()
	#set_deferred("hitbox.monitorable", false)
	#set_deferred("hitbox.monitoring", false)
	#kill_timer.start()
	#await kill_timer.timeout
	queue_free()
