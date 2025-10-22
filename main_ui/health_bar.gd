extends ProgressBar

var player: Player


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	Bus.player_lost_hp.connect(on_player_lost_hp)
	update_value()


func update_value():
	value = player.hp / 100
	modulate.r = max_value - value
	modulate.g = value


func on_player_lost_hp():
	update_value()
