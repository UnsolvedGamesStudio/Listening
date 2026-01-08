extends Interactable

@onready var interaction_area: Area3D = %InteractionArea

var original_scale:= Vector3.ONE


func _ready() -> void:
	original_scale = scale


func _physics_process(delta: float) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		return
	
	if player.los.get_collider() == interaction_area and global_position.distance_to(player.global_position) < Vars.interact_range:
		looked_at_by_player(true)
	else:
		looked_at_by_player(false)


func activate():
	max_out_dopamine()


func max_out_dopamine():
	Vars.dopamine = Vars.max_dopamine


func looked_at_by_player(on: bool):
	if on:
		if scale == original_scale * 1.1:
			return
		
		scale = original_scale * 1.1
	else:
		if scale == original_scale:
			return
		
		scale = original_scale
