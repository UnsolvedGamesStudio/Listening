extends Node

const INTERACT_SIGIL = preload("uid://b0tw8jr20jhhj")

const RETICLE = preload("uid://b7mmj4bh7r1aa")
const RETICLE_PRESSED = preload("uid://cvx1igefaxkfg")
const RETICLE_OPEN = preload("uid://dhqpx2xr22di")

var reticle: TextureRect

var P: Player
var los: RayCast3D
var interact_range:= 4.0

var animating_reticle_pressed:= false


func _ready() -> void:
	reticle = get_tree().get_first_node_in_group("reticle")
	P = get_parent()


func _physics_process(delta: float) -> void:
	update_looked_at_object()


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	
	interact()


func update_looked_at_object():
	if P.check_los() == null:
		toggle_looked_at_object(false)
		P.current_los_collider = null
		return
	
	if not P.current_los_collider == P.check_los():
		toggle_looked_at_object(false)
		P.current_los_collider = P.check_los()
		toggle_looked_at_object(true)


func toggle_looked_at_object(on: bool):
	
	if P.current_los_collider == null:
		if is_instance_valid(reticle):
			if animating_reticle_pressed == false:
				reticle.texture = RETICLE
		
		return
	
	if check_distance(P.current_los_collider.owner) >= interact_range:
		return
	
	if P.current_los_collider.owner.has_method("looked_at_by_player"):
		if animating_reticle_pressed == false:
			reticle.texture = RETICLE_OPEN
		
		P.current_los_collider.owner.looked_at_by_player(on)


func check_distance(object: Node3D):
	return object.global_position.distance_to(P.global_position)


func interact():
	var success = Bgm.check_accuracy()
	
	if success == "missed":
		return
	
	reticle_pressed_show()
	activate_item()
	
	if not Vars.last_activated_circle == null:
		Vars.last_activated_circle.texture = INTERACT_SIGIL


func activate_item():
	var collider:= P.current_los_collider
	
	if collider == null:
		return
	
	var object: = collider.owner
	
	if check_distance(object) >= interact_range:
		return
	
	if "activate_on_interact" in object:
		if object.activate_on_interact == false:
			return
	
	if not object.has_method("activate"):
		return
	
	
	object.activate()


func reticle_pressed_show():
	animating_reticle_pressed = true
	reticle.texture = RETICLE_PRESSED
	await get_tree().create_timer(0.15).timeout
	reticle.texture = RETICLE
	animating_reticle_pressed = false
