extends RigidBody3D
class_name Projectile
## Todo: Use raycast to check los
## Todo: Support piercing and hit modes
## Todo: Load stats from resource
## Todo: Override element color
const POP_TEXTURE = preload("uid://cyk5g3u4ymo2g")
const DESTROYED_VFX:= preload("uid://dotmsm333w37o")
const TERRAIN_LAYER:= 2

@onready var sprite_3d: Sprite3D = %Sprite3D
@onready var hitbox: Area3D = %Hitbox
@onready var kill_timer: Timer = %KillTimer
@onready var omni_light_3d: OmniLight3D = %OmniLight3D

@export var sfx: AudioStreamPlayer3D

@export_category("Stats")
@export var damage: float = 50.0
@export var speed: float = 60.0
@export var max_distance: float = 10.0
#@export var max_lifetime: float = 10.0
@export var hitbox_radius: float = 0.5
@export var gravity: Vector3 = Vector3(0.0, 0.0, 0.0)

@export_category("Behavior")
@export var destroy_on_entity:= true
@export var destroy_on_terrain:= true
@export var bouncy:= false
@export var speed_up_on_bounce:= 0.0
@export var cannon_ball:= false
@export_range(1.01, 1.2) var cannon_ball_friction:= 1.05
@export var momentum_decay_rate:= 0.0
#@export var piercing:= false

#enum hit_modes {ONCE, REPEAT}
#@export var hit_mode:= hit_modes.ONCE
#@export var repeat_hit_cooldown: float = 0.1

@export_file_path() var projectile_effect_path:= ""

@export_category("Appearance")
@export var color:= Color.WHITE
@export var produce_destroyed_vfx:= true

var override_velocity:= true

var origin_node: Node3D
var direction:= Vector3.ZERO
var starting_position:= Vector3.ZERO
var distance_traveled:= 0.0
var starting_speed:= speed
var previous_position:= Vector3.ZERO

var hit_entities:= {} # collider : true
var hit_cooldowns:= {} # collider : timer

var destroyed:= false

signal hit_body(hit_pos: Vector3, hit_normal: Vector3, body: Node)
signal hitbox_hit_body(hit_pos: Vector3, body: RigidBody3D)


func _ready() -> void:
	sprite_3d.modulate = color
	starting_position = origin_node.global_position
	previous_position = starting_position
	body_shape_entered.connect(on_body_shape_entered)
	hitbox.body_entered.connect(on_hitbox_body_entered)
	hitbox.area_entered.connect(on_hitbox_area_entered)
	init_projectile_effect()
	enter()
	
	if cannon_ball == true:
		apply_impulse(direction * (speed / 10.0))
	else:
		physics_material_override = null
		gravity_scale = 0.0


func init_projectile_effect():
	if projectile_effect_path == "":
		return
	
	if not FileAccess.file_exists(projectile_effect_path):
		printerr(self, ": projectile_effect has invalid path")
		return
	
	var effect_scene: PackedScene = load(projectile_effect_path)
	var effect_inst: ProjectileEffect = effect_scene.instantiate()
	effect_inst.projectile = self
	add_child(effect_inst)


func _physics_process(delta: float) -> void:
	if destroyed == true:
		return
	
	move(delta)
	decay_speed(delta)
	calculate_distance()
	if distance_traveled >= max_distance:
		destroy()


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
			bounce_off(normal)
		
		if check_destroy(body, normal) == true:
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


func bounce_off(normal):
	speed += speed_up_on_bounce
	direction = direction.bounce(normal).normalized()


func enter():
	pass


func destroy(hit_normal:= Vector3.ZERO):
	if destroyed == true:
		return
	
	if not sfx == null:
		sfx.play()
	
	destroyed = true
	sprite_3d.hide()
	freeze = true
	omni_light_3d.queue_free()
	spawn_destroyed_vfx(hit_normal)
	
	kill_timer.start(5.0)
	await kill_timer.timeout
	queue_free()


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


func on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	handle_collision(body)


func on_hitbox_body_entered(body):
	if body.owner.has_signal("hit_by_projectile"):
		body.owner.hit_by_projectile.emit(self)
		hitbox_hit_body.emit(global_position, body)
	
	if bouncy == true:
		return
	
	if destroy_on_entity == true:
		destroy()


func on_hitbox_area_entered(area: Area3D):
	pass
