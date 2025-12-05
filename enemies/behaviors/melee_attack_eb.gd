extends EnemyBehavior
class_name MeleeAttackEB

@onready var sfx: AudioStreamPlayer3D = %SFX

var melees_every_x_beat:= 4
var melee_range:= 1
var melee_damage:= 20.0

var attack_anim: AnimationPlayer


func enter() -> void:
	set_stats()
	attack_anim = O.attack_anim
	Bus.beat.connect(on_beat)


func set_stats():
	var data: EnemyData = O.data
	
	if data == null:
		printerr(self, " of ", O, ": data not found")
		return
	
	melees_every_x_beat = data.melees_every_x_beat
	melee_range = data.melee_range
	melee_damage = data.melee_damage


func melee_attack():
	sfx.play()
	O.used_melee.emit()
	play_attack_anim()
	
	var ray_collider: Node = O.raycast_hit_player()
	
	if ray_collider.owner is ShellObject:
		ray_collider.owner.take_damage(melee_damage)
		return
	
	Find.P().take_damage(melee_damage, O)


func play_attack_anim():
	if attack_anim == null:
		return
	
	attack_anim.play("attack")


func check_melee():
	if O.enabled == false:
		return
	
	if O.sees_player == false:
		return
	
	if O.is_moving == true:
		return
	
	if O.within_tiles_to_player(melee_range) == false:
		return
	
	melee_attack()


func on_beat(beat_count: int):
	if enabled == false:
		return
	
	var melee_speed:= melees_every_x_beat
	
	if melees_every_x_beat == 0:
		melee_speed = 99999
	
	var correct_beat_for_melee:= beat_count % melee_speed == 0
	
	if correct_beat_for_melee:
		check_melee()
