extends EnemyBehavior
class_name RangedAttackEB

const PROJECTILE = preload("uid://bwaev5gyis5tp")
const DEFAULT_PROJECTILE_TEXTURE = preload("uid://dgygswxu7j8ds")

var enabled:= true

var shoots_every_x_beat:= 6
var projectile_range:= 2
var projectile_damage:= 10.0
var projectile_speed:= 60.0

var body_damage:= 10.0
var impassable:= false
var attack_anim: AnimationPlayer

var melee_range:= 1


func _ready() -> void:
	Bus.beat.connect(on_beat)
	attack_anim = O.attack_anim
	
	find_melee_range()


func find_melee_range():
	for behavior: EnemyBehavior in get_parent().get_children():
		if behavior is MeleeAttackEB:
			melee_range = behavior.melee_range


func ranged_attack():
	if not attack_anim == null:
		attack_anim.play("ranged_attack")
	
	create_projectile()


func check_ranged():
	if O.sees_player == false:
		return
	
	if O.within_distance_to_player(projectile_range) == false:
		return
	
	if O.within_distance_to_player(melee_range) == true:
		return
	
	ranged_attack()


func create_projectile():
	var projectile_inst: Projectile = PROJECTILE.instantiate()
	
	projectile_inst.damage = projectile_damage
	projectile_inst.speed = projectile_speed
	projectile_inst.max_distance = float(projectile_range) + 3.0
	projectile_inst.player = player
	projectile_inst.target_point = player.enemy_aim_point.global_position
	projectile_inst.origin_node = O
	
	get_parent().add_child(projectile_inst)
	
	projectile_inst.sprite_3d.texture = DEFAULT_PROJECTILE_TEXTURE
	projectile_inst.hitbox.set_collision_layer_value(6, true)
	projectile_inst.global_position = O.sprite_3d.global_position


func on_beat(beat_count: int):
	if enabled == false:
		return
	
	var ranged_speed:= shoots_every_x_beat
	
	if shoots_every_x_beat == 0:
		ranged_speed = 99999
	
	var correct_beat_for_shoot:= beat_count % ranged_speed == 0
	
	if correct_beat_for_shoot:
		check_ranged()
