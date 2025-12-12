extends UnwalledCell
class_name ElevatorCell

@onready var arrow: Sprite3D = %Arrow

@export var slowness:= 0.33

var starting_height:= 0.0
var desired_height:= 1.0
var target_height:= 0.0
var moving:= false


func _ready() -> void:
	starting_height = global_position.y
	cell.cell_collision.area_entered.connect(on_cell_collision_area_entered)
	await get_tree().create_timer(0.0).timeout
	set_desired_height()


func set_desired_height():
	var starting_floor:= cell.starting_floor
	
	if not starting_floor in Vars.floor_heights:
		return
	
	if not starting_floor + 1 in Vars.floor_heights:
		push_error(self, ": No higher floor was set")
		return
	
	desired_height = Vars.floor_heights[starting_floor + 1]
	target_height = desired_height


func _physics_process(delta: float) -> void:
	if moving == false:
		return
	
	move_passengers()


func activate(player):
	tween_height(player)


func tween_height(player):
	var tween:= create_tween()
	var tween_length: float = slowness * abs( abs( global_position.y ) -abs( target_height) )
	moving = true
	tween.tween_property(self, "global_position:y", target_height, tween_length)
	await tween.finished
	swap_target_height()
	moving = false
	player.can_act = true


func swap_target_height():
	var current_height:= global_position.y
	var will_go_up:= current_height == starting_height
	var will_go_down:= current_height == desired_height
	
	if will_go_up:
		target_height = desired_height
		arrow.flip_v = false
	
	if will_go_down:
		target_height = starting_height
		arrow.flip_v = true


func move_passengers():
	var passengers:= cell.occupants
	
	if passengers == []:
		return
	
	for passenger in passengers:
		if not passenger is Player:
			return
		
		passenger.global_position.y = global_position.y


func on_cell_collision_area_entered(area: Area3D):
	if not area.is_in_group("player_collision"):
		return
	
	var player:= area.owner
	await Bus.player_moved
	player.can_act = false
	activate(player)
