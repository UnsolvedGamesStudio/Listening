extends Forgetter
class_name EntityForgetter

@onready var mesh_instance_3d: MeshInstance3D = %MeshInstance3D
@onready var label_3d: Sprite3D = %Label3D
@onready var label: Label = %Label


func enter():
	if previously_collected == true:
		queue_free()
	
	Bus.enemy_died.connect(on_enemy_died)
	update_label()


func update_label():
	if not puzzle_id in TriggersManager.to_die_ids:
		label_3d.hide()
		return
	
	label.text = str(TriggersManager.to_die_ids[puzzle_id])


func triggered():
	queue_free()


func on_enemy_died(enemy: Enemy):
	if not "puzzle_id" in enemy:
		return
	
	if not enemy.puzzle_id == puzzle_id:
		return
	
	update_label()
