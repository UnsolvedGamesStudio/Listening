extends Node

@onready var player_hp_label: Label = $PlayerHPLabel
@onready var enemy_hp_label: Label = $EnemyHPLabel
@onready var level_label: Label = $LevelLabel

var measure_spacer:= 0

var player_hp:= 100
var enemy_hp:= 150

var level:= 0


func _ready() -> void:
	update_ui_all()
	Bus.beat_played.connect(on_beat)
	Bus.player_attacked.connect(on_player_attacked)


func on_beat(): 
	#measure_spacer += 1
	#if measure_spacer < 4: 
		#return
	#
	#measure_spacer = 0
	
	player_hp -= 10
	#if player_hp <= 0:
		#get_tree().quit()
	update_ui_all()


func on_player_attacked(damage: int):
	enemy_hp -= damage
	if enemy_hp <= 0:
		level += 1
		enemy_hp = 150 + (level * 20)
		player_hp = 100 + (level * 10)
	
	update_ui_all()


func update_ui_all():
	player_hp_label.text = str("HP ", player_hp)
	enemy_hp_label.text = str("Enemy's HP ", enemy_hp)
	level_label.text = str("Level ", level + 1)
