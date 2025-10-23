extends Node
class_name EnemyBehavior

@onready var O: Enemy
@onready var player: Player


func _enter_tree() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		printerr(self, ": player not found")
