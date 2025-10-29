extends Node3D
class_name HealingPickup

@onready var sprite_3d: Sprite3D = %Sprite3D
@onready var area_3d: Area3D = %Area3D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var healed_amount:= 50.0


func _ready() -> void:
	Vars.synapses_left += 1
	area_3d.area_entered.connect(on_area_3d_area_entered)
	Bus.beat.connect(on_beat)


func destroy():
	queue_free()


func on_beat(beat_count: int):
	if beat_count % 2 == 0:
		animation_player.play("beat")


func on_area_3d_area_entered(area: Area3D):
	Vars.synapses += 1
	Bus.synapse_picked_up.emit()
	destroy()
