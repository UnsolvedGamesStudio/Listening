extends EnemyBehavior
class_name MovementEB
## Todo: make enemy not attack while moving
#@onready var movement_raycast: RayCast3D = %MovementRaycast

#@export var see_through_walls:= false

var moves_every_x_beat:= 2
var movement_speed:= 4
var aggro_distance:= 4.0

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
	aggro_distance = data.aggro_distance
	projectile_range = data.projectile_range


func move():
	var target_cell = get_next_cell_on_path()
	
	if target_cell == null:
		return
	
	if not O.occupied_cell == null:
		target_cell.remove_occupant(O)
	
	if cell_occupied(target_cell) == true:
		return
	
	target_cell.add_occupant(O)
	Find.P().update_move_to_cell_indicator()
	
	var move_speed: float = Bgm.rhythm_notifier.bpm / (movement_speed * 100)
	var tween:= get_tree().create_tween()
	tween.tween_property(O, "global_position:x", target_cell.global_position.x, move_speed)
	tween.tween_property(O, "global_position:z", target_cell.global_position.z, move_speed)
	
	tween.play()


func get_next_cell_on_path():
	var path:= PathFinder.get_cell_path(O.occupied_cell.cell_grid_position, Vars.player_cell.cell_grid_position, false)
	
	if path == []:
		return null
	
	if path.size() < 2:
		return null
	
	var cell_position: Vector2i = path[1]
	return PathFinder.cell_nodes[cell_position]


func cell_occupied(cell: Cell):
	for occupant in cell.occupants:
		if not is_instance_valid(occupant):
			continue
		
		if occupant is Enemy:
			print(occupant.data.name)
			return true
	
	return false


func check_movement():
	if O.enabled == false:
		return
	
	if O.aware_of_player == false:
		return
	
	if not O.within_distance_to_player(aggro_distance) == true:
		return
	
	if within_attack_range("melee") == true:
		return
	
	if within_attack_range("ranged") == true and O.sees_player == true:
		return
	
	move()


func within_attack_range(attack_range):
	if attack_range == "melee":
		if O.preferred_range == O.ranges.MELEE and O.within_distance_to_player(melee_range) == true:
			return true
	
	if attack_range == "ranged":
		if O.preferred_range == O.ranges.RANGED and O.within_distance_to_player(projectile_range) == true:
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
