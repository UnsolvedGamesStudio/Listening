extends Node


func _ready() -> void:
	Bus.player_used_combo.connect(on_player_used_combo)


func on_player_used_combo(combo_name: StringName):
	if self.has_method(combo_name):
		call(combo_name, combo_name)


func activate_player_ability(ability_name: StringName):
	var player: Player = Find.P()
	
	for ability in player.abilities.get_children():
	
		if not ability is PlayerAbility:
			return
		
		if ability.name == ability_name:
			
			ability.activate()


func spell_1(combo_name):
	print("do a spell 1")


func spell_2(combo_name):
	print("do a spell 2")


func spell_3(combo_name):
	print("do a spell 3")


func spell_4(combo_name):
	print("do a spell 4")


func spell_5(combo_name):
	print("do a spell 5")


func spell_6(combo_name):
	print("do a spell 6")


func spell_7(combo_name):
	print("do a spell 7")

## Shell (JOY + JOY + SAD)
func spell_8(combo_name):
	activate_player_ability("ShellAbility")


func spell_9(combo_name):
	print("do a spell 9")


func spell_10(combo_name):
	print("do a spell 10")

## Wish (SAD + SAD + JOY)
func spell_11(combo_name):
	Find.P().heal(50.0)


func spell_12(combo_name):
	print("do a spell 12")

## Violence (ANG = ANG + ANG)
func spell_13(combo_name):
	pass


func spell_14(combo_name):
	print("do a spell 14")


func spell_15(combo_name):
	print("do a spell 15")


func spell_16(combo_name):
	print("do a spell 16")
