extends EnemyBehavior
class_name MovementEB

var enabled:= true
var movement_raycast: RayCast3D

var moves_every_x_beat:= 2
var movement_speed:= 4.0

var melee_range:= 1
var projectile_range:= 2


func _ready() -> void:
	movement_raycast = O.movement_raycast
	if movement_raycast == null:
		printerr(self, " of ", O, ": movement_raycast not found")
		return
	
	Bus.beat.connect(on_beat)
	for behavior in get_parent().get_children():
		if behavior is MeleeAttackEB:
			melee_range = behavior.melee_range
		
		if behavior is RangedAttackEB:
			projectile_range = behavior.projectile_range


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
	
	tween.tween_property(O, "global_position:x", target_cell.global_position.x, move_speed)
	tween.tween_property(O, "global_position:z", target_cell.global_position.z, move_speed)
	
	tween.play()


func check_movement():
	if O.sees_player == false:
		return
	
	if O.preferred_range == O.ranges.MELEE and O.within_distance_to_player(melee_range) == true:
		return
	
	if O.preferred_range == O.ranges.RANGED and O.within_distance_to_player(projectile_range) == true:
		return
	
	move()


func on_beat(beat_count: int):
	if enabled == false:
		return
	
	var move_speed:= moves_every_x_beat
	
	if moves_every_x_beat == 0:
		move_speed = 99999
	
	var correct_beat_for_move:= beat_count % move_speed == 0
	
	if correct_beat_for_move:
		check_movement()
