extends EnemyBehavior
class_name MovementEB
## Todo: make enemy not attack while moving
## Todo: let enemies optionally chase you without seeing you until you leave their range
@export var see_through_walls:= false

var moves_every_x_beat:= 2
var movement_speed:= 4

var melee_range:= 1
var projectile_range:= 2


func enter() -> void:
	set_stats()
	
	Bus.beat.connect(on_beat)
	
	for behavior in get_parent().get_children():
		if behavior is MeleeAttackEB:
			melee_range = behavior.melee_range
		
		if behavior is RangedAttackEB:
			projectile_range = behavior.projectile_range


func set_stats():
	var data: EnemyResource = O.data
	
	if data == null:
		printerr(self, " of ", O, ": data not found")
		return
	
	moves_every_x_beat = data.moves_every_x_beat
	movement_speed = data.movement_speed
	projectile_range = data.projectile_range


func move():
	var movement_raycast = O.movement_raycast
	
	if movement_raycast == null:
		printerr(self, " of ", O, ": movement_raycast not found")
		return
	
	if movement_raycast.get_collider() == null:
		return
	
	var raycast_result = movement_raycast.get_collider().owner
	
	if raycast_result == null:
		return
	
	if not raycast_result is Cell:
		return
	
	var target_cell: Cell = raycast_result
	
	var move_speed: float = Bgm.rhythm_notifier.bpm / (movement_speed * 100)
	
	if target_cell == null:
		return
	
	if cell_occupied(target_cell) == true:
		return
	
	var tween:= get_tree().create_tween()
	tween.tween_property(O, "global_position:x", target_cell.global_position.x, move_speed)
	tween.tween_property(O, "global_position:z", target_cell.global_position.z, move_speed)
	
	tween.play()


func cell_occupied(cell: Cell):
	for occupant in cell.occupants:
		if not is_instance_valid(occupant):
			return
		
		if occupant is Enemy:
			return true
	
	return false


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
	
	var move_rate:= moves_every_x_beat
	
	if moves_every_x_beat == 0:
		move_rate = 99999
	
	var correct_beat_for_move:= beat_count % move_rate == 0
	
	if correct_beat_for_move:
		check_movement()
