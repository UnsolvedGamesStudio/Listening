extends Node3D
class_name Enemy

const PROJECTILE = preload("uid://bwaev5gyis5tp")
const DEFAULT_PROJECTILE_TEXTURE = preload("uid://dgygswxu7j8ds")

@onready var sprite_3d: Sprite3D = %Sprite3D
@onready var hurtbox: Area3D = %Hurtbox
@onready var idle_anim: AnimationPlayer = %IdleAnim
@onready var attack_anim: AnimationPlayer = %AttackAnim
@onready var health_bar: ProgressBar = %HealthBar
@onready var vision_raycast: RayCast3D = %VisionRaycast
@onready var movement_raycast: RayCast3D = %MovementRaycast

@export var enabled:= true

## Stats
@export var preferred_range: ranges
enum ranges{MELEE, RANGED}

@export_range(0, 6) var melees_every_x_beat:= 4
@export_range(0, 6) var shoots_every_x_beat:= 6
@export_range(0, 6) var moves_every_x_beat:= 2

@export_range(0, 5) var melee_range:= 1
@export var melee_damage:= 20.0

@export_range(0, 10) var projectile_range:= 2
@export var projectile_damage:= 10.0
@export var projectile_speed:= 30.0

@export var body_damage:= 10.0
@export var impassable:= false

@export var vision_limit:= 10.0
@export var movement_speed:= 4.0


var occupied_cell: Cell
var on_top_of_player:= false
var sees_player:= false
var look_at_direction:= Vector3.ZERO
var player: Player

## Stats
var max_hp:= 100.0:
	set(value):
		max_hp = clampf(value, 1.0, 9999.9)

var hp:= 100.0:
	set(value):
		hp = clampf(value, 0.0, max_hp)


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	Bus.beat.connect(on_beat)
	hurtbox.area_entered.connect(on_area_entered)
	update_health_bar_value()


func _physics_process(delta: float) -> void:
	check_on_top_of_player()
	check_sees_player()
	
	if not get_direction_to_player() == null:
		movement_raycast.target_position = get_direction_to_player()
	
	if on_top_of_player == true:
		sprite_3d.modulate.a = 0.0
	else:
		sprite_3d.modulate.a = 1.0


func take_damage(amount: float):
	hp -= amount
	update_health_bar_value()
	
	if hp <= 0:
		die()


func die():
	queue_free()


func melee_attack():
	player.take_damage(melee_damage)
	attack_anim.play("attack")


func ranged_attack():
	attack_anim.play("ranged_attack")
	create_projectile()


func on_hurtbox_area_entered(area: Area3D):
	if not "damage" in area.owner:
		return
	
	take_damage(area.owner.damage)


func move():
	var raycast_result = movement_raycast.get_collider().owner
	
	if raycast_result == null:
		return
	
	if not raycast_result is Cell:
		return
	
	var target_cell: Cell = raycast_result
	
	var tween:= get_tree().create_tween()
	var move_speed: float = Bgm.rhythm_notifier.bpm / (movement_speed * 100)
	
	if target_cell == null:
		return
	
	tween.tween_property(self, "global_position:x", target_cell.global_position.x, move_speed)
	tween.tween_property(self, "global_position:z", target_cell.global_position.z, move_speed)
	
	tween.play()


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


func check_melee():
	if within_distance_to_player(melee_range) == false:
		return
	
	melee_attack()


func check_ranged():
	if sees_player == false:
		return
	
	if within_distance_to_player(projectile_range) == false:
		return
	
	if within_distance_to_player(melee_range) == true:
		return
	
	ranged_attack()


func check_movement():
	if sees_player == false:
		return
	
	if preferred_range == ranges.MELEE and within_distance_to_player(melee_range) == true:
		return
	
	if preferred_range == ranges.RANGED and within_distance_to_player(projectile_range) == true:
		return
	
	move()


func check_on_top_of_player():
	var player_distance = (global_position - player.global_position).length()
	
	if player_distance <= 1.5 and on_top_of_player == false:
		on_top_of_player = true
	
	if player_distance > 1.5 and on_top_of_player == true:
		on_top_of_player = false


func check_sees_player():
	var player_distance = (global_position - player.global_position).length()
	if player_distance > vision_limit:
		sees_player = false
		return
	
	vision_raycast.look_at(player.global_position + Vector3(0.0001, 0.0001, 0.0001))
	
	if vision_raycast.get_collider() == null:
		return
	
	if vision_raycast.get_collider().is_in_group("player_collision"):
		sees_player = true
	else:
		sees_player = false


func create_projectile():
	var projectile_inst: Projectile = PROJECTILE.instantiate()
	
	projectile_inst.damage = projectile_damage
	projectile_inst.speed = projectile_speed
	projectile_inst.player = player
	projectile_inst.target_point = player.global_position
	projectile_inst.origin_node = self
	
	get_parent().add_child(projectile_inst)
	
	projectile_inst.sprite_3d.texture = DEFAULT_PROJECTILE_TEXTURE
	projectile_inst.hitbox.set_collision_layer_value(6, true)
	projectile_inst.global_position = global_position


func update_health_bar_value():
	health_bar.value = hp / 100
	health_bar.modulate.r = (health_bar.max_value - health_bar.value)
	health_bar.modulate.g = health_bar.value


func on_area_entered(area: Area3D):
	if not "owner" in area:
		return
	
	if not "damage" in area.owner:
		return
	
	take_damage(area.owner.damage)


func on_beat(beat_count: int):
	if enabled == false:
		return
	
	var melee_speed:= melees_every_x_beat
	var ranged_speed:= shoots_every_x_beat
	var move_speed:= moves_every_x_beat
	
	if melees_every_x_beat == 0:
		melee_speed = 99999
	if shoots_every_x_beat == 0:
		ranged_speed = 99999
	if moves_every_x_beat == 0:
		move_speed = 99999
	
	var correct_beat_for_attack:= beat_count % melee_speed == 0
	var correct_beat_for_shoot:= beat_count % ranged_speed == 0
	var correct_beat_for_move:= beat_count % move_speed == 0
	
	if correct_beat_for_attack:
		check_melee()
	
	if correct_beat_for_shoot:
		check_ranged()
	
	if correct_beat_for_move:
		check_movement()
