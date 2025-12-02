extends Node

var to_die_ids: Dictionary[int, int] = {} ## Puzzle id : Amount left

func _ready() -> void:
	Bus.enemy_died.connect(on_enemy_died)


func update_ids(enemy_id):
	if not enemy_id in to_die_ids:
		return
	
	if enemy_id in to_die_ids:
		to_die_ids[enemy_id] -= 1
	
	if to_die_ids[enemy_id] == 0:
		Bus.necessary_enemies_died.emit(enemy_id)


func on_enemy_died(enemy: Enemy):
	if not "puzzle_id" in enemy:
		return
	
	if enemy.puzzle_id == -1:
		return
	
	update_ids(enemy.puzzle_id)
