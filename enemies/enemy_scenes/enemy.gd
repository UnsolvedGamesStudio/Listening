extends Node3D
class_name Enemy
## Todo: Before adding new enemies, make every enemy nothing but a collection of behavior nodes; whatever it takes to make every enemy self-sufficiant
## Todo: Add indication that enemy already dropped the synapse (and other similar cases) / hasn't dropped it yet
## Todo: Make collectible drops add themselves to stats (see music box)
## Todo: Make them aggro when hit
const PROJECTILE = preload("uid://6n70akjpdb5c")
const DEFAULT_PROJECTILE_TEXTURE = preload("uid://dgygswxu7j8ds")
const TERRAIN_LAYER:= 2
const PLAYER_LAYER:= 4
const SHELL_LAYER:= 11

@onready var to_animate: Node3D = %ToAnimate
@onready var sprite_3d: Sprite3D = %Sprite3D
@onready var idle_anim: AnimationPlayer = %IdleAnim
@onready var attack_anim: AnimationPlayer = %AttackAnim
#@onready var vision_raycast: RayCast3D = %VisionRaycast
@onready var behaviors_container: Node = %Behaviors
@onready var health_bar: ProgressBar = %HealthBar
@onready var enemy_indicator: EnemyIndicator = %EnemyIndicator

@export var data: EnemyData = preload("uid://c8heqp3v32a1n")

@export var enabled:= true
@export var puzzle_id:= -1
@export var save_id: String = ""

var preferred_range
enum ranges{MELEE, RANGED, CONTACT}

var body_damage:= 10.0
var impassable:= false

var vision_limit:= 10.0
var vertical_vision_range:= 2.0

var occupied_cell: Cell
var on_top_of_player:= false
var sees_player:= false
var aware_of_player:= false
var is_moving:= false

var counts_towards_goal:= true

signal hit_by_player_damage(projectile: Projectile)
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
	vertical_vision_range = data.vertical_vision_range
	counts_towards_goal = data.counts_towards_goal


func _physics_process(delta: float) -> void:
	check_on_top_of_player()
	check_sees_player()
	update_enemy_indicator()
	
	if on_top_of_player == true:
		set_sprite_alpha(0.0)
	else:
		set_sprite_alpha(1.0)

## Todo: Turn into behavior
func drop_loot():
	if data == null:
		printerr(self, " : data not found")
		return
	
	if data.drop == null:
		return
	
	if not ResourceLoader.exists(data.drop):
		printerr(self, ": data.drop has invalid path")
		return
	
	var drop_scene: PackedScene = load(data.drop)
	var drop_inst:= drop_scene.instantiate()
	
	if not drop_inst is Node:
		printerr(self, ": drop_inst is not a node")
		return
	
	var inst_save_id:= save_id + "_" + str(0)
	
	if SaveManager.check_node_collected(drop_inst, inst_save_id) == true:
		drop_inst.queue_free()
		return
	
	set_inst_save_id(drop_inst, inst_save_id)
	
	Find.layout().add_child(drop_inst)
	drop_inst.global_position = global_position


func set_inst_save_id(drop_inst, inst_save_id):
	if not "save_id" in drop_inst:
		return
	
	drop_inst.save_id = inst_save_id


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
	
	if direction_to_player.z == Vars.DIRECTIONS["north"].z:
		chosen_directions.append(Vars.DIRECTIONS["north"])
	
	if direction_to_player.x == Vars.DIRECTIONS["east"].x:
		chosen_directions.append(Vars.DIRECTIONS["east"])
	
	if direction_to_player.z == Vars.DIRECTIONS["south"].z:
		chosen_directions.append(Vars.DIRECTIONS["south"])
	
	if direction_to_player.x == Vars.DIRECTIONS["west"].x:
		chosen_directions.append(Vars.DIRECTIONS["west"])
	if chosen_directions == []:
		return
	
	return chosen_directions.pick_random()


func within_tiles_to_player(distance: float):
	var player_cell:= Vars.player_cell
	
	distance *= Vars.cell_size
	if player_cell == null:
		return false
	
	if occupied_cell == null:
		printerr(self, ": occupied_cell not found")
		return false
	
	var height_diff: float = abs( abs( occupied_cell.global_position.y ) -abs( player_cell.global_position.y ) )
	
	if height_diff > 0.5:
		return false
	
	var own_cell_pos:= occupied_cell.global_position
	var player_cell_pos:= player_cell.global_position
	var cell_distance:= roundi( (own_cell_pos - player_cell_pos).length() )
	
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
	
	if not raycast_hit_player() == null:
		sees_player = true
		aware_of_player = true
	else:
		sees_player = false


func raycast_hit_player():
	var self_pos:= sprite_3d.global_position
	var player_pos:= Find.P().enemy_aim_point.global_position
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	
	query.from = self_pos
	query.to = player_pos
	query.collide_with_areas = true
	query.collision_mask = (1 << TERRAIN_LAYER - 1) | (1 << PLAYER_LAYER - 1) | (1 << SHELL_LAYER - 1)
	
	var result = space_state.intersect_ray(query)
	
	if result == {}:
		return null
	
	var collider: Node = result["collider"]
	
	if not collider.owner is Player and not collider.owner is ShellObject:
		return null
	
	return collider
