extends EnemyBehavior
class_name MovementEB
## Todo: Make enemy not attack while moving
## Todo: Rename enemy behaviors "enemy ___"
## Todo: Add variable to enemy data: "keeps_chasing" and "see_through_walls" with relevant effects
## Todo: Make enemies jump up or down when moving to a cell with different height
var moves_every_x_beat:= 2
var movement_speed:= 4
var aggro_distance:= 4.0
var can_move_diagonally:= false

var melee_range:= 1
var projectile_range:= 2


func enter() -> void:
	set_stats()
	
	Bus.beat.connect(on_beat)


func set_stats():
	var data: EnemyData = O.data
	
	if data == null:
		push_error(self, " of ", O, ": data not found")
		return
	
	moves_every_x_beat = data.moves_every_x_beat
	movement_speed = data.movement_speed
	aggro_distance = data.aggro_distance
	can_move_diagonally = data.can_move_diagonally
	
	melee_range = data.melee_range
	projectile_range = data.projectile_range


func move_towards_player():
	var own_cell_pos:= O.occupied_cell.global_position
	var player_cell_pos:= Vars.player_cell.global_position
	
	var target_cell: Cell
	var allow_diagonals:= can_move_diagonally
	var ignore_occupants: Array = [O, Find.P()]
	
	target_cell = NavGraph.get_next_cell(
		own_cell_pos, 
		player_cell_pos, 
		allow_diagonals, 
		ignore_occupants, 
		false)
	
	move_to_cell(target_cell)


func move_to_cell(target_cell: Cell):
	if target_cell == null:
		return
	
	if not O.occupied_cell == null:
		target_cell.remove_occupant(O)
	
	if cell_occupied(target_cell) == true:
		return
	
	target_cell.add_occupant(O)
	Find.P().update_move_to_cell_indicator()
	
	O.is_moving = true
	
	var move_speed: float = Bgm.rhythm_notifier.bpm / (movement_speed * 100)
	var tween:= get_tree().create_tween()
	
	tween.tween_property(O, "global_position", target_cell.global_position, move_speed)
	
	await tween.finished
	
	O.is_moving = false


func cell_occupied(cell: Cell):
	for occupant in cell.occupants:
		if not is_instance_valid(occupant):
			continue
		
		if occupant is Enemy:
			print(O, "'s movement blocked by: ", occupant.data.name)
			return true
	
	return false


func check_movement():
	if O.enabled == false:
		return
	
	if O.aware_of_player == false:
		return
	
	if not O.within_tiles_to_player(aggro_distance) == true:
		return
	
	if within_attack_range("melee") == true:
		return
	
	if within_attack_range("ranged") == true and O.sees_player == true:
		return
	
	move_towards_player()


func within_attack_range(attack_range):
	if attack_range == "melee":
		if O.preferred_range == O.ranges.MELEE and O.within_tiles_to_player(melee_range) == true:
			return true
	
	if attack_range == "ranged":
		if O.preferred_range == O.ranges.RANGED and O.within_tiles_to_player(projectile_range) == true:
			return true
	
	return false


func on_beat(beat_count: int):
	if enabled == false:
		return
	
	var move_rate:= moves_every_x_beat
	
	if moves_every_x_beat == 0:
		move_rate = 99999
	
	var correct_beat_for_move:= beat_count % move_rate == 0
	
	if correct_beat_for_move:
		check_movement()
