extends Pickup
class_name HealingPickup

var healed_amount:= 50.0


func on_activated():
	var player: Player = get_tree().get_first_node_in_group("player")
	player.heal(healed_amount)
