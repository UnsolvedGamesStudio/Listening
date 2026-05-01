extends RigidBody3D
class_name Projectile
## Todo: Use raycast to check los
## Todo: Support pierce_entities and repeat
## Todo: Override element color
## Todo: Add phys material if cannon ball instead of removing it
## Todo: Make a body for terrain and a body for entities collision
## Todo: Add option to intercept enemy projectiles
## Todo: Add default spell data
const POP_TEXTURE = preload("uid://cyk5g3u4ymo2g")
const DESTROYED_VFX:= preload("uid://dotmsm333w37o")
const TERRAIN_LAYER:= 2

@onready var sprite_3d: Sprite3D = %Sprite3D
@onready var hitbox: Area3D = %Hitbox
@onready var kill_timer: Timer = %KillTimer
@onready var lifetime: Timer = %Lifetime
@onready var omni_light_3d: OmniLight3D = %OmniLight3D

@export var data: ProjectileData
@export var sfx: AudioStreamPlayer3D

var damage: float = 10.0:
	set(value):
		damage = clampf(value, 0.0, 999999.9)

var speed: float = 70.0
var max_distance: float = 9.0
var max_lifetime: float = 5.0

var destroy_on_entity:= true
var destroy_on_terrain:= true
var bouncy:= false
var speed_mult_on_bounce:= 1.0

var cannon_ball:= false
var cannon_ball_bounce:= 0.3
var cannon_ball_friction:= 1.05
var momentum_decay_rate:= 0.0
var pierce_entities:= false

var repeat_hit_cooldown: float = 0.1 ## Unused

var projectile_effect_path:= ""

var color:= Color.WHITE
var produce_destroyed_vfx:= true

var origin_node: Node3D
var direction:= Vector3.ZERO
var starting_position:= Vector3.ZERO
var distance_traveled:= 0.0
var previous_position:= Vector3.ZERO

var destroyed:= false

signal hit_body(hit_pos: Vector3, hit_normal: Vector3, body: Node)
signal hitbox_hit_body(hit_pos: Vector3, body: RigidBody3D)
signal was_destroyed


func _ready() -> void:
	body_shape_entered.connect(on_body_shape_entered)
	hitbox.body_entered.connect(on_hitbox_body_entered)
	hitbox.area_entered.connect(on_hitbox_area_entered)
	lifetime.timeout.connect(on_lifetime_timeout)
	init_data()
	if pierce_entities == true:
		set_collision_mask_value(3, false)
	
	sprite_3d.modulate = color
	lifetime.start(max_lifetime)
	init_position()
	init_projectile_effect()
	enter()
	
	if cannon_ball == true:
		apply_impulse(direction * (speed / 10.0))
	else:
		physics_material_override = null
		gravity_scale = 0.0


func init_position():
	starting_position = origin_node.global_position
	previous_position = starting_position
	
	if data == null:
		return
	
	var spawn_rand:= data.spawn_randomness
	if spawn_rand == 0.0:
		return
	
	await get_tree().create_timer(0.0).timeout
	global_position = get_random_point_in_front(Find.P().camera, spawn_rand)


func init_data():
	if data == null:
		return
	
	if not data.texture == null:
		sprite_3d.texture = data.texture
		sprite_3d.hframes = data.h_frames
		sprite_3d.animate = data.animate
	
	damage *= data.damage_mult
	speed *= data.speed_mult
	max_distance *= data.max_distance_mult
	max_lifetime *= data.max_lifetime_mult
	destroy_on_entity = data.destroy_on_entity
	destroy_on_terrain = data.destroy_on_terrain
	bouncy = data.bouncy
	speed_mult_on_bounce = data.speed_mult_on_bounce
	
	cannon_ball = data.cannon_ball
	if cannon_ball == true:
		cannon_ball_friction = data.cannon_ball_friction
		cannon_ball_bounce = data.cannon_ball_bounce
	
	momentum_decay_rate = data.momentum_decay_rate
	pierce_entities = data.pierce_entities
	repeat_hit_cooldown = data.repeat_hit_cooldown
	
	if projectile_effect_path == "":
		projectile_effect_path = data.projectile_effect_path
	
	color = data.color
	produce_destroyed_vfx = data.produce_destroyed_vfx


func init_projectile_effect():
	if projectile_effect_path == "":
		return
	
	if not ResourceLoader.exists(projectile_effect_path):
		push_error(self, ": projectile_effect has invalid path")
		return
	
	var effect_scene: PackedScene = load(projectile_effect_path)
	var effect_inst: ProjectileEffect = effect_scene.instantiate()
	effect_inst.projectile = self
	add_child(effect_inst)


func _physics_process(delta: float) -> void:
	in_process()
	
	if destroyed == true:
		return
	
	move(delta)
	decay_speed(delta)
	calculate_distance()
	if distance_traveled >= max_distance:
		on_expired()
		destroy()

## Todo: Make compatible with any origin node
func get_random_point_in_front(player: Node3D, radius: float, forward_offset: float = 0.0) -> Vector3:
	var origin = player.global_position
	var forward = -player.global_transform.basis.z
	var right = player.global_transform.basis.x
	var up = player.global_transform.basis.y
	
	radius *= Find.P().scale.x * 2.0
	
	# Optional: move the spawn plane forward in front of the face
	var center = origin + forward * forward_offset
	
	# Random point in a circle (uniform distribution)
	var angle = randf_range(0.0, TAU)
	var dist = sqrt(randf()) * radius
	
	# Build offset in the plane (right + up)
	var offset = (right * cos(angle) + up * sin(angle)) * dist
	
	return center + offset


func move(delta):
	if cannon_ball == false:
		apply_force(direction * speed * (delta * 60))
	elif get_colliding_bodies():
		linear_velocity /= (cannon_ball_friction)


func calculate_distance():
	distance_traveled += previous_position.distance_to(global_position)
	previous_position = global_position


func decay_speed(delta):
	if momentum_decay_rate <= 0.0:
		return
	
	var rate: float = distance_traveled / max_distance * momentum_decay_rate * (delta * 60)
	speed = lerpf(speed, 0.0, rate)


func handle_collision(body: Node):
	var colliders:= get_colliding_bodies()
	
	var state = PhysicsServer3D.body_get_direct_state(get_rid())
	if colliders == null:
		return
	
	for contact in state.get_contact_count():
		var normal = state.get_contact_local_normal(contact)
		
		hit_body.emit(global_position, normal, body)
		
		if bouncy == true:
			bounce_off(body, normal)
		
		if check_destroy(body, normal) == true:
			on_destroyed()
			destroy(normal)


func check_destroy(body: Node, normal) -> bool:
	if bouncy == true:
		return false
	
	if body.get_collision_layer_value(13) == true:
		return false
	
	if body.get_collision_layer_value(TERRAIN_LAYER) == true\
	and destroy_on_terrain == true:
		return true
	
	if body.get_collision_layer_value(TERRAIN_LAYER) == false\
	and destroy_on_entity == true:
		return true
	
	return false


func bounce_off(body, normal):
	direction = direction.bounce(normal).normalized()
	
	if body.get_collision_layer_value(13) == true:
		return
	
	speed *= speed_mult_on_bounce
	on_bounce()


func enter():
	pass


func in_process():
	pass


func destroy(hit_normal:= Vector3.ZERO):
	if destroyed == true:
		return
	
	if not sfx == null:
		sfx.play()
	
	was_destroyed.emit()
	destroyed = true
	sprite_3d.hide()
	disable_hitbox()
	set_collision_layer_value(2, false)
	set_collision_layer_value(3, false)
	set_collision_layer_value(13, false)
	set_collision_mask_value(2, false)
	set_collision_mask_value(3, false)
	set_collision_mask_value(4, false)
	set_collision_mask_value(13, false)
	freeze = true
	omni_light_3d.queue_free()
	spawn_destroyed_vfx(hit_normal)
	
	kill_timer.start(5.0)
	await kill_timer.timeout
	queue_free()


func disable_hitbox():
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)


func spawn_destroyed_vfx(hit_normal:= Vector3.ZERO):
	if not projectile_effect_path == "":
		return
	
	if produce_destroyed_vfx == false:
		return
	
	var pop: Sprite3D = DESTROYED_VFX.instantiate()
	pop.texture = POP_TEXTURE
	pop.modulate.a = 0.5
	get_parent().add_child(pop)
	pop.scale *= 2.0
	var offset:= pop.texture.get_size().x / 400
	pop.global_position = global_position + hit_normal * offset


func on_bounce():
	pass


func on_destroyed():
	pass


func on_expired():
	pass


func on_lifetime_timeout():
	if destroyed == true:
		return
	
	on_expired()
	destroy()


func on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	handle_collision(body)


func on_hitbox_body_entered(body):
	if body.owner.has_signal("hit_by_player_damage"):
		body.owner.hit_by_player_damage.emit(self)
		hitbox_hit_body.emit(global_position, body)
	
	if bouncy == true:
		return
	
	if destroy_on_entity == true:
		destroy()


func on_hitbox_area_entered(area: Area3D):
	pass
