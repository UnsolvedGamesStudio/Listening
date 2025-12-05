extends EnemyBehavior
class_name RangedAttackEB

const PROJECTILE = preload("uid://6n70akjpdb5c")
const DEFAULT_PROJECTILE_TEXTURE = preload("uid://dgygswxu7j8ds")

@onready var sfx: AudioStreamPlayer3D = %SFX

var shoots_every_x_beat:= 6
var projectile_enabled:= true
var projectile_range:= 2
var projectile_damage:= 10.0
var projectile_speed:= 25.0
var projectile_scale:= Vector3(1.0, 1.0, 1.0)

var attack_anim: AnimationPlayer

var melee_range:= 0


func enter() -> void:
	set_stats()
	Bus.beat.connect(on_beat)
	attack_anim = O.attack_anim
	
	find_melee_range()


func set_stats():
	var data: EnemyData = O.data
	
	if data == null:
		printerr(self, " of ", O, ": data not found")
		return
	
	shoots_every_x_beat = data.shoots_every_x_beat
	
	projectile_enabled = data.projectile_enabled
	projectile_range = data.projectile_range
	projectile_damage = data.projectile_damage
	projectile_speed = data.projectile_speed
	projectile_scale = data.projectile_scale


func find_melee_range():
	for behavior in get_parent().get_children():
		if behavior is MeleeAttackEB:
			melee_range = behavior.melee_range


func ranged_attack():
	if not attack_anim == null:
		attack_anim.play("ranged_attack")
	
	O.fired_projectile.emit()
	sfx.play()
	create_projectile()


func check_ranged():
	if projectile_enabled == false:
		return
	
	if O.enabled == false:
		return
	
	if O.sees_player == false:
		return
	
	if O.is_moving == true:
		return
	
	if O.within_tiles_to_player(projectile_range) == false:
		return
	
	if O.within_tiles_to_player(melee_range) == true:
		return
	
	ranged_attack()


func create_projectile():
	var data: EnemyData = O.data
	var projectile_inst: Projectile = PROJECTILE.instantiate()
	
	projectile_inst.damage = projectile_damage
	projectile_inst.speed = projectile_speed
	projectile_inst.max_distance = float(projectile_range) + 3.0
	projectile_inst.origin_node = O
	
	Find.layout().add_child(projectile_inst)
	
	projectile_inst.scale = projectile_scale
	projectile_inst.sprite_3d.texture = data.projectile_texture
	projectile_inst.global_position = O.sprite_3d.global_position
	
	var projectile_direction:= projectile_inst.global_position.direction_to(Find.P().enemy_aim_point.global_position)
	projectile_inst.direction = projectile_direction


func on_beat(beat_count: int):
	if enabled == false:
		return
	
	var ranged_speed:= shoots_every_x_beat
	
	if shoots_every_x_beat == 0:
		ranged_speed = 99999
	
	var correct_beat_for_shoot:= beat_count % ranged_speed == 0
	
	if correct_beat_for_shoot:
		check_ranged()
