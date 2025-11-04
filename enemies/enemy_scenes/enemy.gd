extends Node3D
class_name Enemy
## Todo: save healthbar as scene
const PROJECTILE = preload("uid://bwaev5gyis5tp")
const DEFAULT_PROJECTILE_TEXTURE = preload("uid://dgygswxu7j8ds")

@onready var to_animate: Node3D = %ToAnimate
@onready var sprite_3d: Sprite3D = %Sprite3D
@onready var idle_anim: AnimationPlayer = %IdleAnim
@onready var attack_anim: AnimationPlayer = %AttackAnim
@onready var vision_raycast: RayCast3D = %VisionRaycast
@onready var movement_raycast: RayCast3D = %MovementRaycast
@onready var behaviors_container: Node = %Behaviors
@onready var enemy_collision: Area3D = %EnemyCollision

@onready var health_bar: ProgressBar = %HealthBar
@onready var enemy_indicator: EnemyIndicator = %EnemyIndicator

@export var data: EnemyResource = preload("uid://c8heqp3v32a1n")
var preferred_range
enum ranges{MELEE, RANGED, CONTACT}

var body_damage:= 10.0
var impassable:= false

var vision_limit:= 10.0

var occupied_cell: Cell
var on_top_of_player:= false
var sees_player:= false

var counts_towards_goal:= true

signal took_damage(amount: float)
signal used_melee
signal fired_projectile
signal projectile_hit_player


func _ready() -> void:
	init_stats()
	init_behaviors()
	if counts_towards_goal == true:
		Vars.living_enemies.append(self)


func init_behaviors():
	for behavior in behaviors_container.get_children():
		if not "O" in behavior:
			return
		
		behavior.O = self


func init_stats():
	preferred_range = data.preferred_range
	body_damage = data.body_damage
	impassable = data.impassable
	vision_limit = data.vision_limit
	counts_towards_goal = data.counts_towards_goal


func _physics_process(delta: float) -> void:
	check_on_top_of_player()
	check_sees_player()
	update_enemy_indicator()
	
	if not get_direction_to_player() == null:
		movement_raycast.target_position = get_direction_to_player()
	
	if on_top_of_player == true:
		set_sprite_alpha(0.0)
	else:
		set_sprite_alpha(1.0)


func set_sprite_alpha(amount: float):
	if sprite_3d == null:
		return
	
	sprite_3d.modulate.a = amount


func update_enemy_indicator():
	if sees_player == false:
		enemy_indicator.mesh_instance_3d.transparency = 0.6
		enemy_indicator.mesh_instance_3d.scale = Vector3(0.5, 0.5, 0.5)
	
	if sees_player == true:
		enemy_indicator.mesh_instance_3d.transparency = 0.0
		enemy_indicator.mesh_instance_3d.scale = Vector3(1.0, 1.0, 1.0)


func get_direction_to_player():
	var chosen_directions: Array[Vector3i]= []
	var direction_to_player: Vector3i = round(global_position.direction_to(Find.P().global_position))
	
	if direction_to_player.z == Vars.directions["north"].z:
		chosen_directions.append(Vars.directions["north"])
	
	if direction_to_player.x == Vars.directions["east"].x:
		chosen_directions.append(Vars.directions["east"])
	
	if direction_to_player.z == Vars.directions["south"].z:
		chosen_directions.append(Vars.directions["south"])
	
	if direction_to_player.x == Vars.directions["west"].x:
		chosen_directions.append(Vars.directions["west"])
	if chosen_directions == []:
		return
	
	return chosen_directions.pick_random()


func within_distance_to_player(distance: int):
	if Vars.player_cell == null:
		return false
	
	if occupied_cell == null:
		printerr(self, ": occupied_cell not found")
		return false
	
	var cell_distance:= roundi( (occupied_cell.cell_grid_position - Vars.player_cell.cell_grid_position).length() )
	
	if cell_distance <= distance:
		return true
	else:
		return false


func check_on_top_of_player():
	var player_distance = (global_position - Find.P().global_position).length()
	
	if player_distance <= 1.5 and on_top_of_player == false:
		on_top_of_player = true
	
	if player_distance > 1.5 and on_top_of_player == true:
		on_top_of_player = false


func check_sees_player():
	var player_distance = (global_position - Find.P().enemy_aim_point.global_position).length()
	if player_distance > vision_limit:
		sees_player = false
		return
	
	
	vision_raycast.look_at(Find.P().enemy_aim_point.global_position + Vector3(0.0001, 0.0001, 0.0001))
	
	if vision_raycast.get_collider() == null:
		return
	
	if vision_raycast.get_collider().is_in_group("player_collision"):
		sees_player = true
	else:
		sees_player = false
