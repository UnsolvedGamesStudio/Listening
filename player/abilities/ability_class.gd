extends Node
class_name PlayerAbility

var player: Player


func _ready() -> void:
	if not get_parent().get_parent() is Player:
		printerr(self, ": parent's parent is not player, freeing self")
		queue_free()
	
	player = get_parent().get_parent()
	
	if player == null:
		printerr(self, ": player not found, freeing self")
		queue_free()


func enter():
	pass


func activate():
	pass
