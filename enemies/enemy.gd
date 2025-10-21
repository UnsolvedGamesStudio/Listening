extends Node3D
class_name Enemy

const PROJECTILE = preload("uid://bwaev5gyis5tp")

@onready var sprite_3d: Sprite3D = %Sprite3D
@onready var hurtbox: Area3D = %Hurtbox
@onready var movement_raycasts: Node3D = %MovementRaycasts
@onready var idle_anim: AnimationPlayer = %IdleAnim
@onready var attack_anim: AnimationPlayer = %AttackAnim
@onready var health_bar: ProgressBar = %HealthBar

## Stats
@export_range(0, 5) var attack_speed:= 3
@export_range(0, 5) var move_speed:= 3

@export_range(0, 5) var melee_range:= 1
@export var melee_damage:= 20.0

@export_range(0, 10) var projectile_range:= 2
@export var projectile_damage:= 10.0
@export var projectile_speed:= 30.0

@export var body_damage:= 10.0

var occupied_cell: Vector2i = Vector2i.ZERO
var on_top_of_player:= false
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
	Bus.first_of_two_beats.connect(on_first_of_two_beats)
	Bus.first_of_four_beats.connect(on_first_of_four_beats)
	Bus.first_of_eight_beats.connect(on_first_of_eight_beats)
	Bus.first_of_twelve_beats.connect(on_first_of_twelve_beats)
	hurtbox.area_entered.connect(on_hurtbox_area_entered)
	update_health_bar_value()


func _physics_process(delta: float) -> void:
	check_on_top_of_player()
	
	if on_top_of_player == true:
		sprite_3d.modulate.a = 0.0
	else:
		sprite_3d.modulate.a = 1.0


func check_on_top_of_player():
	var player_distance = (global_position - player.global_position).length()
	
	if player_distance <= 1.5 and on_top_of_player == false:
		on_top_of_player = true
	
	if player_distance > 1.5 and on_top_of_player == true:
		on_top_of_player = false


func within_distance_to_player(distance: int):
	var cell_distance = roundi( (occupied_cell - Vars.player_cell).length() )
	
	if cell_distance <= distance:
		return true
	else:
		return false


func take_damage(amount: float):
	hp -= amount
	update_health_bar_value()
	
	if hp <= 0:
		die()


func die():
	queue_free()


func update_health_bar_value():
	health_bar.value = hp / 100
	health_bar.modulate.r = (max_hp - hp) / 100
	health_bar.modulate.g = hp / 100


func melee_attack():
	if within_distance_to_player(melee_range) == false:
		return
	
	player.take_damage(melee_damage)
	attack_anim.play("attack")


func ranged_attack():
	if within_distance_to_player(projectile_range) == false:
		return
	
	if within_distance_to_player(melee_range) == true:
		return
	
	create_projectile()


func create_projectile():
	var projectile_inst: Projectile = PROJECTILE.instantiate()
	
	projectile_inst.damage = projectile_damage
	projectile_inst.speed = projectile_speed
	projectile_inst.player = player
	projectile_inst.target_point = player.global_position
	projectile_inst.origin_node = self
	
	get_parent().add_child(projectile_inst)
	
	projectile_inst.hitbox.set_collision_layer_value(6, true)
	projectile_inst.global_position = global_position


func on_hurtbox_area_entered(area: Area3D):
	if not "damage" in area.owner:
		return
	
	take_damage(area.owner.damage)


func check_attacks():
	melee_attack()
	ranged_attack()


func check_movement():
	pass


func on_beat():
	if attack_speed == 5:
		check_attacks()
	
	if move_speed == 5:
		check_movement()


func on_first_of_two_beats():
	if attack_speed == 4:
		check_attacks()
	
	if move_speed == 4:
		check_movement()


func on_first_of_four_beats():
	if attack_speed == 3:
		check_attacks()
	
	if move_speed == 3:
		check_movement()


func on_first_of_eight_beats():
	if attack_speed == 2:
		check_attacks()
	
	if move_speed == 2:
		check_movement()


func on_first_of_twelve_beats():
	if attack_speed == 1:
		check_attacks()
	
	if move_speed == 1:
		check_movement()
