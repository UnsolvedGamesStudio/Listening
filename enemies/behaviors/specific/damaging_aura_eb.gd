extends EnemyBehavior
class_name DamagingAuraEB

@onready var area_3d: Area3D = %Area3D

@export var damage_per_tick:= 0.05

var main: MainScene 
var player_inside:= false


func _ready() -> void:
	main = get_tree().get_first_node_in_group("main_scene")
	area_3d.area_entered.connect(on_area_3d_area_entered)
	area_3d.area_exited.connect(on_area_3d_area_exited)


func _physics_process(delta: float) -> void:
	if player_inside == false:
		return
	
	find_player().take_damage(damage_per_tick)


func on_area_3d_area_entered(area: Area3D):
	if not area.is_in_group("player_collision"):
		return
	
	Filters.noise_fade.play("appear")
	Filters.noise_shift.play("shift")
	player_inside = true


func on_area_3d_area_exited(area: Area3D):
	if not area.is_in_group("player_collision"):
		return
	
	Filters.noise_fade.play_backwards("appear")
	Filters.noise_shift.stop()
	player_inside = false
