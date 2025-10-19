extends Node3D
class_name Enemy

@onready var sprite_3d: Sprite3D = $ToMove/Sprite3D
@onready var hurtbox: Area3D = $ToMove/Hurtbox
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var occupied_cell: Cell
var near_player:= false
var look_at_direction:= Vector3.ZERO
var player: Player


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	var cam_pos = player.camera.global_position
	
	look_at_direction = Vector3(cam_pos.x + 0.0001, cam_pos.y + 0.0001, cam_pos.z + 0.0001)
	
	look_at(look_at_direction)


#func check_near_player():
	#if near_player == false and Vars.occupied_cell == 
