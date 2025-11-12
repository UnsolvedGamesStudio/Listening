extends RigidBody3D
class_name Projectile

const POP_TEXTURE = preload("uid://cyk5g3u4ymo2g")

@onready var sprite_3d: Sprite3D = %Sprite3D
@onready var hitbox: Area3D = %Hitbox
@onready var kill_timer: Timer = %KillTimer
@onready var omni_light_3d: OmniLight3D = %OmniLight3D

@export var sfx: AudioStreamPlayer3D

var destroyed:= false

var origin_node: Node3D
var projectile_effect_path:= ""
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

signal hit_terrain(hit_pos: Vector3, hit_normal: Vector3)
signal hit_player
signal hit_enemy(enemy)


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
	
	detect_walls()
	
	apply_impulse(direction * speed * delta)
	distance_traveled = starting_position.distance_to(global_position)
	if distance_traveled >= max(2.5, max_distance):
		destroy()


func detect_walls():
	var space_state = get_world_3d().direct_space_state
	var from_pos = global_position
	var to_pos = global_position + direction * speed * get_physics_process_delta_time() * 2.0
	
	var query = PhysicsRayQueryParameters3D.create(from_pos, to_pos)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var hit_pos: Vector3 = result.position
		var hit_normal: Vector3 = result.normal
		collided(result.collider)
		hit_terrain.emit(hit_pos, hit_normal)


func destroy():
	if destroyed == true:
		return
	
	destroyed = true
	sprite_3d.hide()
	freeze = true
	
	omni_light_3d.queue_free()
	hitbox.get_child(0).set_deferred("disabled", true) 
	spawn_destroyed_fx()
	
	await kill_timer.timeout
	
	sprite_3d.hide()
	kill_timer.start(5.0)
	await kill_timer.timeout
	queue_free()


func spawn_destroyed_fx():
	if not projectile_effect_path == "":
		return
	
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


func collided(body: CollisionObject3D):
	if not sfx == null:
		sfx.play()
	
	destroy()
