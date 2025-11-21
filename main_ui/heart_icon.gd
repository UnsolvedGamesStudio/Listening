extends Sprite2D

@onready var timer: Timer = %Timer


func _ready() -> void:
	Bus.beat.connect(on_beat)


func on_beat(beat_count: int):
	var player: Player = get_tree().get_first_node_in_group("player")
	
	if player.hp > (player.max_hp / 4.0):
		health_normal(beat_count)
	else:
		health_critical(beat_count)


func health_normal(beat_count: int):
	if beat_count % 2 == 0:
		frame = 1
		timer.start()
		await timer.timeout
		frame = 0


func health_critical(beat_count: int):
	var player:= get_tree().get_first_node_in_group("player")
	frame = 1
	timer.start()
	await timer.timeout
	frame = 0
