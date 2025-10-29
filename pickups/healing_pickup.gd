extends Node3D
class_name SynapsePickup

@onready var sprite_3d: Sprite3D = %Sprite3D
@onready var area_3d: Area3D = %Area3D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var healed_amount:= 50.0


func _ready() -> void:
	area_3d.area_entered.connect(on_area_3d_area_entered)
	Bus.beat.connect(on_beat)


func destroy():
	queue_free()


func on_beat(beat_count: int):
	if beat_count % 2 == 0:
		animation_player.play("flap")


func on_area_3d_area_entered(area: Area3D):
	if not area.is_in_group("player_collision"):
		return
	
	if not area.owner.has_method("heal"):
		return
	
	area.owner.heal(healed_amount)
	destroy()
