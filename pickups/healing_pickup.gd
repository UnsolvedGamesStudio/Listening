extends Pickup
class_name HealingPickup

@onready var sfx: AudioStreamPlayer = %SFX

var healed_amount:= 75.0


func on_activated():
	sfx.reparent(get_parent())
	sfx.play()
	var player: Player = get_tree().get_first_node_in_group("player")
	player.heal(healed_amount)
	animate_heal()


func animate_heal():
	var hp_bar:= get_tree().get_first_node_in_group("player_hp_bar")
	hp_bar.get_child(0).play("healed")
