extends RigidBody3D
class_name Projectile
## Todo: Use raycast to check los
## Todo: Support piercing and hit modes
## Todo: differentiate terrain vs enemy bounce
const POP_TEXTURE = preload("uid://cyk5g3u4ymo2g")
const DESTROYED_VFX:= preload("uid://dotmsm333w37o")
const TERRAIN_LAYER:= 3

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

@export_category("Abilities")
@export var hitbox_is_aura:= false
@export var bouncy:= false
#@export var piercing:= false

#enum hit_modes {ONCE, REPEAT}
#@export var hit_mode:= hit_modes.ONCE
#@export var repeat_hit_cooldown: float = 0.1

@export var projectile_effect_path:= ""

@export_category("Appearance")
@export var color:= Color.WHITE
@export var produce_destroyed_vfx:= true

var override_velocity:= true

var origin_node: Node3D
var direction:= Vector3.ZERO
var starting_position:= Vector3.ZERO
var distance_traveled:= 0.0

var hit_entities:= {} # collider : true
var hit_cooldowns:= {} # collider : timer

var destroyed:= false

signal hit_body(hit_pos: Vector3, hit_normal: Vector3)
signal hit_entity(hit_pos: Vector3, hit_normal: Vector3)


func _ready() -> void:
	sprite_3d.modulate = color
	starting_position = origin_node.global_position
	body_shape_entered.connect(on_body_shape_entered)
	hitbox.body_entered.connect(on_hitbox_body_entered)
	hitbox.area_entered.connect(on_hitbox_area_entered)
	
	init_projectile_effect()
	enter()


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
	move(delta)


func move(delta):
	apply_force(direction * speed * (delta * 60))
	
	distance_traveled = starting_position.distance_to(global_position)
	if distance_traveled >= max(2.5, max_distance):
		destroy()


func handle_collision(body: Node):
	var colliders:= get_colliding_bodies()
	
	var state = PhysicsServer3D.body_get_direct_state(get_rid())
	if colliders == null:
		return
	
	for contact in state.get_contact_count():
		var normal = state.get_contact_local_normal(contact)
		
		hit_body.emit(global_position, normal)
		
		if bouncy == true:
			bounce_off(normal)
		if bouncy == false:
			destroy(normal)


func bounce_off(normal):
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
	
	if hitbox_is_aura == true or bouncy == true:
		return
	
	destroy()


func on_hitbox_area_entered(area: Area3D):
	pass
