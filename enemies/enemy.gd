extends Node3D
class_name Enemy

const PROJECTILE = preload("uid://bwaev5gyis5tp")
const DEFAULT_PROJECTILE_TEXTURE = preload("uid://dgygswxu7j8ds")

@onready var sprite_3d: Sprite3D = %Sprite3D
@onready var idle_anim: AnimationPlayer = %IdleAnim
@onready var attack_anim: AnimationPlayer = %AttackAnim
@onready var vision_raycast: RayCast3D = %VisionRaycast
@onready var movement_raycast: RayCast3D = %MovementRaycast
@onready var behaviors: Node = %Behaviors
@onready var enemy_collision: Area3D = %EnemyCollision

@onready var health_bar: ProgressBar = %HealthBar
@onready var enemy_indicator: EnemyIndicator = %EnemyIndicator

@export var data: EnemyResource
@export var preferred_range: ranges
enum ranges{MELEE, RANGED, CONTACT}

@export var body_damage:= 10.0
@export var impassable:= false

@export var vision_limit:= 10.0

var occupied_cell: Cell
var on_top_of_player:= false
var sees_player:= false
var player: Player


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	init_behaviors()


func init_behaviors():
	for behavior: NodePath in data.behaviors:
		var behavior_inst = load(behavior).instantiate()
		behavior_inst.O = self
		behaviors.add_child(behavior_inst)


func _physics_process(delta: float) -> void:
	check_on_top_of_player()
	check_sees_player()
	update_enemy_indicator()
	
	if not get_direction_to_player() == null:
		movement_raycast.target_position = get_direction_to_player()
	
	if on_top_of_player == true:
		sprite_3d.modulate.a = 0.0
	else:
		sprite_3d.modulate.a = 1.0


func update_enemy_indicator():
	if sees_player == false:
		enemy_indicator.mesh_instance_3d.transparency = 0.6
		enemy_indicator.mesh_instance_3d.scale = Vector3(0.5, 0.5, 0.5)
	
	if sees_player == true:
		enemy_indicator.mesh_instance_3d.transparency = 0.0
		enemy_indicator.mesh_instance_3d.scale = Vector3(1.0, 1.0, 1.0)


func get_direction_to_player():
	var chosen_directions: Array[Vector3i]= []
	var direction_to_player: Vector3i = round(global_position.direction_to(player.global_position))
	
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
	var cell_distance:= roundi( (occupied_cell.cell_grid_position - Vars.player_cell.cell_grid_position).length() )
	
	if cell_distance <= distance:
		return true
	else:
		return false


func check_on_top_of_player():
	var player_distance = (global_position - player.global_position).length()
	
	if player_distance <= 1.5 and on_top_of_player == false:
		on_top_of_player = true
	
	if player_distance > 1.5 and on_top_of_player == true:
		on_top_of_player = false


func check_sees_player():
	var player_distance = (global_position - player.enemy_aim_point.global_position).length()
	if player_distance > vision_limit:
		sees_player = false
		return
	
	vision_raycast.look_at(player.enemy_aim_point.global_position + Vector3(0.0001, 0.0001, 0.0001))
	
	if vision_raycast.get_collider() == null:
		return
	
	if vision_raycast.get_collider().is_in_group("player_collision"):
		sees_player = true
	else:
		sees_player = false
