extends EnemyBehavior
class_name MeleeAttackEB

var enabled:= true
var melees_every_x_beat:= 4
var melee_range:= 1
var melee_damage:= 20.0

var attack_anim: AnimationPlayer


func _ready() -> void:
	attack_anim = O.attack_anim
	
	Bus.beat.connect(on_beat)


func melee_attack():
	player.take_damage(melee_damage)
	
	if not attack_anim == null:
		attack_anim.play("attack")


func check_melee():
	if O.sees_player == false:
		return
	
	if O.within_distance_to_player(melee_range) == false:
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
