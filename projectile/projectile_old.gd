extends RigidBody3D
#class_name Projectile
## Todo: make collision funcs into component
const POP_TEXTURE = preload("uid://cyk5g3u4ymo2g")
const DESTROYED_FX:= preload("uid://dotmsm333w37o")
const TERRAIN_LAYER:= 3

@onready var sprite_3d: Sprite3D = %Sprite3D
@onready var hitbox: Area3D = %Hitbox
@onready var kill_timer: Timer = %KillTimer
@onready var omni_light_3d: OmniLight3D = %OmniLight3D
@onready var collision_size: CollisionShape3D = %CollisionSize

@export var sfx: AudioStreamPlayer3D

@export_category("Stats")
@export var damage: float = 50.0
@export var speed: float = 60.0
@export var max_distance: float = 10.0
#@export var max_lifetime: float = 10.0
@export var hitbox_radius: float = 0.5
@export var gravity: Vector3 = Vector3(0.0, 0.0, 0.0)

@export_category("Abilities")
@export var piercing: bool = false
#@export var bouncy: bool = false

enum hit_modes {ONCE, REPEAT}
@export var hit_mode:= hit_modes.ONCE
@export var repeat_hit_cooldown: float = 0.1

@export var projectile_effect_path:= ""

@export_category("Appearance")
@export var color:= Color.WHITE
@export var produce_destroyed_fx:= true

var override_velocity:= true

var origin_node: Node3D
var direction:= Vector3.ZERO
var starting_position:= Vector3.ZERO
var distance_traveled:= 0.0

var hit_entities:= {} # collider : true
var hit_cooldowns:= {} # collider : timer

var destroyed:= false

signal hit_terrain()
signal hit_entity(entity: Node3D)


func _ready() -> void:
	hitbox.area_entered.connect(on_hitbox_area_entered)
	sprite_3d.modulate = color
	starting_position = origin_node.global_position
	init_projectile_effect()
	
	enter()


func enter():
	pass


func init_projectile_effect():
	if projectile_effect_path == "":
		return
	
	if not ResourceLoader.exists(projectile_effect_path):
		push_error(self, ": projectile_effect has invalid path")
		return
	
	var effect_scene: PackedScene = load(projectile_effect_path)
	var effect_inst: ProjectileEffect = effect_scene.instantiate()
	
	#effect_inst.projectile = self
	add_child(effect_inst)


func _physics_process(delta: float) -> void:
	if destroyed:
		return
	
	move_projectile(delta)
	apply_gravity(delta)
	handle_collisions(delta)
	
	distance_traveled = starting_position.distance_to(global_position)
	if distance_traveled >= max(2.5, max_distance):
		destroy()


func move_projectile(delta: float) -> void:
	if override_velocity == false:
		return
	
	var move_vec = direction * speed * delta
	apply_impulse(move_vec)


func apply_gravity(delta: float) -> void:
	direction += gravity * delta


#region || Collision Detection
func handle_collisions(delta: float) -> void:
	var move_distance = speed * delta
	
	process_terrain_collision(move_distance)
	
	process_entity_collision(delta, move_distance)


func process_terrain_collision(move_distance: float) -> void:
	# 1) broad-phase shape check
	if check_terrain_shape(move_distance) == null:
		# nothing intersected
		return
	
	var shape_hit: Dictionary = check_terrain_shape(move_distance)
	
	# 2) fine-phase raycast for proper hit position + normal
	var from_pos := global_position
	var to_pos := global_position + direction * (move_distance + hitbox_radius)
	
	if get_terrain_raycast_hit(from_pos, to_pos) == null:
		# fallback: shape reported overlap but ray missed (spawn-inside case)
		# approximate a normal (upwards fallback) and report center
		#print(self, ": process_terrain_collision 'else' condition triggered")
		handle_wall_hit(global_position, Vector3.UP)
		return
	
	var ray_hit: Dictionary = get_terrain_raycast_hit(from_pos, to_pos)
	
	handle_wall_hit(ray_hit.position, ray_hit.normal)


func get_terrain_raycast_hit(from_pos: Vector3, to_pos: Vector3):
	var ray_q := PhysicsRayQueryParameters3D.new()
	ray_q.from = from_pos
	ray_q.to = to_pos
	ray_q.exclude = [self]
	ray_q.collision_mask = TERRAIN_LAYER
	ray_q.collide_with_bodies = true
	ray_q.collide_with_areas = false
	ray_q.hit_from_inside = true
	
	var hit := get_world_3d().direct_space_state.intersect_ray(ray_q)
	if hit.size() > 0:
		return hit
	
	return null


func check_terrain_shape(move_distance: float):
	var shape := SphereShape3D.new()
	shape.radius = hitbox_radius
	
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = shape
	q.transform = Transform3D(Basis(), global_position)
	q.motion = direction * move_distance
	q.exclude = [self]
	q.collision_mask = TERRAIN_LAYER
	q.collide_with_bodies = true
	q.collide_with_areas = false
	
	
	var hits := get_world_3d().direct_space_state.intersect_shape(q)
	if hits.size() > 0:
		return hits[0]
	
	return null


func process_entity_collision(delta: float, move_distance: float):
	var space_state = get_world_3d().direct_space_state
	
	var shape = SphereShape3D.new()
	shape.radius = hitbox_radius
	
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis(), global_position)
	query.motion = direction * move_distance
	query.exclude = [self]
	query.collision_mask = collision_mask
	query.collide_with_areas = true
	query.collide_with_bodies = false
	
	var results = space_state.intersect_shape(query)
	for hit in results:
		var collider = hit.collider
		if collider:
			handle_entity_hit(collider, delta)


#func handle_collisions(delta: float) -> void:
	#var move_distance = speed * delta
	#
	## --- Entity Query ---
	#var entity_shape = SphereShape3D.new()
	#entity_shape.radius = hitbox_radius
	#
	#var entity_query = PhysicsShapeQueryParameters3D.new()
	#entity_query.shape = entity_shape
	#entity_query.transform = Transform3D(Basis(), global_position)
	#entity_query.motion = direction * move_distance
	#entity_query.exclude = [self]
	#entity_query.collision_mask = collision_mask  # Only check projectile's target layers
	#entity_query.collide_with_areas = true
	#var space_state = get_world_3d().direct_space_state
	#var entity_results = space_state.intersect_shape(entity_query)
	#
	#for hit in entity_results:
		#var collider = hit.get("collider")
		#if collider:
			#handle_entity_hit(collider, delta)
	#
	## --- Terrain/Wall Query ---
	#var terrain_shape = SphereShape3D.new()
	#terrain_shape.radius = hitbox_radius
#
	#var terrain_query = PhysicsShapeQueryParameters3D.new()
	#terrain_query.shape = terrain_shape
	#terrain_query.transform = Transform3D(Basis(), global_position)
	#terrain_query.motion = direction * move_distance
	#terrain_query.exclude = [self]
	#terrain_query.collision_mask = TERRAIN_LAYER
	#
	#var terrain_results = space_state.intersect_shape(terrain_query)
	#
	#for hit in terrain_results:
		#var collider = hit.get("collider")
		#if collider:
			#var hit_pos = hit.get("position")
			#var hit_normal = hit.get("normal")
			#handle_wall_hit(Vector3.ZERO, Vector3.ZERO)


func handle_wall_hit(hit_pos: Vector3, hit_normal: Vector3) -> void:
	hit_terrain.emit(hit_pos, hit_normal)
	destroy()


func handle_entity_hit(collider: Object, delta: float) -> void:
	if hit_mode == 0:  # once per entity
		if collider in hit_entities:
			return
		
		check_entity_hit(collider)
		
		hit_entities[collider] = true
		
		hit_entity.emit(collider.owner)
		
		if piercing == false:
			destroy()
	
	elif hit_mode == 1:  # repeated hits
		if not can_hit_entity(collider, delta):
			return
		
		check_entity_hit(collider)
		
		if piercing == false:
			destroy()


func can_hit_entity(collider: Object, delta: float) -> bool:
	if collider not in hit_cooldowns:
		hit_cooldowns[collider] = 0.0
	hit_cooldowns[collider] -= delta
	if hit_cooldowns[collider] <= 0:
		hit_cooldowns[collider] = repeat_hit_cooldown
		return true
	return false


func check_entity_hit(collider: Object):
	if not origin_node == null:
		if collider.owner == origin_node:
			return
	
	if collider.is_in_group("enemy_collision"):
		if not collider.owner is Enemy:
			push_error(self, ": owner of collider is not Enemy")
			return
		
		collided_with_enemy(collider.owner)
		return
	
	if collider.is_in_group("player_collision"):
		if not collider.owner is Player:
			push_error(self, ": owner of collider is not Player")
			return
		
		collided_with_player()
		return
	
	if collider.owner is ShellObject:
		collided_with_shield(collider.owner)
		return


func collided_with_enemy(enemy: Enemy):
	pass

#endregion || Collision Detection End


func collided_with_player():
	pass


func collided_with_shield(shield: ShellObject):
	pass


func destroy():
	if destroyed == true:
		return
	
	if not sfx == null:
		sfx.play()
	
	destroyed = true
	sprite_3d.hide()
	freeze = true
	omni_light_3d.queue_free()
	spawn_destroyed_fx()
	
	kill_timer.start(5.0)
	await kill_timer.timeout
	queue_free()


func spawn_destroyed_fx():
	if not projectile_effect_path == "":
		return
	
	if produce_destroyed_fx == false:
		return
	
	var pop:= DESTROYED_FX.instantiate()
	pop.texture = POP_TEXTURE
	pop.modulate.a = 0.5
	get_parent().add_child(pop)
	pop.scale *= 2.0
	pop.global_position = global_position


func on_hitbox_area_entered(area: Area3D):
	pass
