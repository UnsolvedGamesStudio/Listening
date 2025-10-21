extends ProgressBar

var player: Player


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	Bus.player_lost_hp.connect(on_player_lost_hp)
	update_value()


func update_value():
	value = player.hp / 100
	modulate.r = (player.max_hp - player.hp) / 100
	modulate.g = player.hp / 100


func on_player_lost_hp():
	update_value()
