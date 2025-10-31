extends Node

const INTERACT_SIGIL = preload("uid://b0tw8jr20jhhj")

const RETICLE = preload("uid://b7mmj4bh7r1aa")
const RETICLE_PRESSED = preload("uid://cvx1igefaxkfg")
const RETICLE_OPEN = preload("uid://dhqpx2xr22di")

var reticle: TextureRect

var P: Player
var los: RayCast3D

var animating_reticle_pressed:= false


func _ready() -> void:
	reticle = get_tree().get_first_node_in_group("reticle")
	P = get_parent()


#func _physics_process(delta: float) -> void:
	#var collider: Area3D = P.current_los_collider()
	#
	#if collider == null:
		#P.looked_at_object = null
		#return
	#
	#highlight_object(collider)
#
#
#func highlight_object(collider: Area3D):
	#var object:= collider.owner
	#
	#if not "looked_at_by_player" in object:
		#return
	#
	#if should_activate_object(object) == false:
		#object.looked_at_by_player(false)
	#
	#if should_activate_object(object) == true:
		#object.looked_at_by_player(true)


#func should_activate_object(object: Node3D):
	#if not P.looked_at_object == object:
		#return false
	#
	#if check_distance(object) >= interact_range:
		#return false
	#
	#return true


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	
	interact()


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
	var collider: Area3D = P.current_los_collider()
	
	if collider == null:
		return
	
	var object: = collider.owner
	
	if check_distance(object) >= Vars.interact_range:
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
