extends CharacterBody3D
class_name Projectile

const POP_TEXTURE = preload("uid://cyk5g3u4ymo2g")

@onready var sprite_3d: Sprite3D = %Sprite3D
@onready var wall_detect: Area3D = %WallDetect
@onready var hitbox: Area3D = %Hitbox
@onready var kill_timer: Timer = %KillTimer
@onready var omni_light_3d: OmniLight3D = %OmniLight3D

var destroyed:= false

var origin_node: Node3D
var direction:= Vector3.ZERO
var color:= Color.WHITE

var speed:= 60.0
var damage:= 50.0
var max_distance:= 10.0
var produce_destroyed_fx:= true
var linger_time:= 0.08
var destroyed_fx:= preload("uid://dotmsm333w37o")

var starting_position:= Vector3.ZERO
var distance_traveled:= 0.0


func _ready() -> void:
	wall_detect.area_entered.connect(on_wall_detect_area_entered)
	hitbox.area_entered.connect(on_hitbox_area_entered)
	sprite_3d.modulate = color
	starting_position = origin_node.global_position
	enter()


func enter():
	pass


func _physics_process(delta: float) -> void:
	velocity += direction * speed * delta
	distance_traveled = starting_position.distance_to(global_position)
	if distance_traveled >= max(2.5, max_distance):
		destroy()
	
	move_and_slide()


func destroy():
	if destroyed == true:
		return
	
	destroyed = true
	kill_timer.start(linger_time)
	velocity = Vector3.ZERO
	omni_light_3d.queue_free()
	hitbox.get_child(0).set_deferred("disabled", true) 
	wall_detect.get_child(0).set_deferred("disabled", true) 
	spawn_destroyed_fx()
	
	await kill_timer.timeout
	
	sprite_3d.hide()
	kill_timer.start(5.0)
	await kill_timer.timeout
	queue_free()


func spawn_destroyed_fx():
	if produce_destroyed_fx == false:
		return
	
	var pop:= destroyed_fx.instantiate()
	pop.texture = POP_TEXTURE
	pop.modulate.a = 0.5
	get_parent().add_child(pop)
	pop.scale *= 2.0
	pop.global_position = global_position


func on_hitbox_area_entered(area: Area3D):
	if not origin_node == null:
		if not "owner" in area:
			return
		
		if area.owner == origin_node:
			return
	
	destroy()


func on_wall_detect_area_entered(area: Area3D):
	if not origin_node == null:
		if not "owner" in area:
			return
		
		if area.owner == origin_node:
			return
	
	destroy()
