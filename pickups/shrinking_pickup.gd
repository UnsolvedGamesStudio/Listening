extends Pickup
class_name ShrinkingPickup

var shrink_amount:= 5.0


func on_activated():
	var player: Player = get_tree().get_first_node_in_group("player")
	player.shrink(shrink_amount)
