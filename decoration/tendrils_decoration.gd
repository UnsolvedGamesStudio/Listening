extends Node3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var sprite_3d: Sprite3D = %Sprite3D


func _ready() -> void:
	if randf() < 0.5:
		sprite_3d.flip_h = true
	
	scale.y *= randf_range(0.5, 1.5)
	animation_player.speed_scale *= randf_range(0.75, 1.25)
