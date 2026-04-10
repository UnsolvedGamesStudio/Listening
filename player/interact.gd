extends Node
## Todo: Change a shader on interact instead of modulate
const INTERACT_SIGIL = preload("uid://b0tw8jr20jhhj")

const RETICLE = preload("uid://b7mmj4bh7r1aa")
const RETICLE_PRESSED = preload("uid://cvx1igefaxkfg")
const RETICLE_OPEN = preload("uid://dhqpx2xr22di")

var reticle: TextureRect

var P: Player

enum HintNames {INTERACT, PICK_UP, REMEMBER, UNLOCK, OPEN, REPLENISH}
var hints: Dictionary[HintNames, String] = {
	HintNames.INTERACT : "Interact",
	HintNames.PICK_UP : "Pick up",
	HintNames.REMEMBER : "Remember",
	HintNames.UNLOCK : "Unlock",
	HintNames.OPEN : "Open",
	HintNames.REPLENISH : "Replenish dopamine",
}

var tooltip: Label

var animating_reticle_pressed:= false


func _ready() -> void:
	reticle = get_tree().get_first_node_in_group("reticle")
	P = get_parent()
	tooltip = get_tree().get_first_node_in_group("interact_tooltip")
	
	if not P:
		push_error(self, ": Player (P) not found, freeing self")
		queue_free()


func _process(delta: float) -> void:
	update_tooltip()


func _input(event: InputEvent) -> void:
	if get_parent().can_act == false:
		return
	
	if not event.is_action_pressed("interact"):
		return
	
	Bus.beat_press_attempted.emit()
	interact()


func check_distance(object: Node3D):
	return object.global_position.distance_to(P.global_position)


func interact():
	if P.can_interact == false:
		return
	
	reticle_pressed_show()
	activate_item()


func get_collider():
	var collider = P.current_los_collider()
	
	if collider == null:
		return
	
	if not collider.owner is Node3D:
		return
	
	var object: Node3D = collider.owner
	
	if check_distance(object) >= Vars.interact_range:
		return
	
	return object


func update_tooltip():
	var object: Node = get_collider()
	
	if tooltip == null:
		return
	
	if object == null:
		tooltip.text = ""
		return
	
	var tooltip_text:= get_tooltip_key(object)
	
	if tooltip.text == tooltip_text:
		return
	
	tooltip.text = tooltip_text


func get_tooltip_key(object: Node) -> String:
	var returned_string:= ""
	
	if object is Pickup:
		returned_string = hints[HintNames.PICK_UP]
	
	if object is RemembererPickup:
		returned_string = hints[HintNames.REMEMBER]
		
		if not object.player_has_enough():
			returned_string += "?"
	
	if object is Keyhole:
		returned_string = hints[HintNames.UNLOCK]
		
		if not object.has_item():
			returned_string += "?"
	
	if object is MusicBox:
		returned_string = hints[HintNames.OPEN]
	
	if object is DopamineReplenisher:
		returned_string = hints[HintNames.REPLENISH]
	
	return returned_string


func activate_item():
	var object: Node = get_collider()
	
	if object == null:
		return
	
	if "activate_on_interact" in object:
		if object.activate_on_interact == false:
			return
	
	if not object.has_method("activate"):
		return
	
	if "activated" in object:
		if object.activated == true:
			return
	
	if Bgm.check_accuracy(false, false, false) == "missed":
		return
	
	if Vars.last_activated_circle:
		Vars.last_activated_circle.change_texure(INTERACT_SIGIL)
	
	object.activate()


func reticle_pressed_show():
	if not is_instance_valid(reticle):
		return
	
	animating_reticle_pressed = true
	reticle.texture = RETICLE_PRESSED
	await get_tree().create_timer(0.15).timeout
	reticle.texture = RETICLE
	animating_reticle_pressed = false
