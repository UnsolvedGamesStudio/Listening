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


func _input(event: InputEvent) -> void:
	if get_parent().can_act == false:
		return
	
	if not event.is_action_pressed("interact"):
		return
	
	Bus.beat_press_attempted.emit()
	interact()


func trigger_beat_check():
	Bgm.check_accuracy()
	
	if not Vars.last_activated_circle == null:
		Vars.last_activated_circle.change_texure(INTERACT_SIGIL)


func check_distance(object: Node3D):
	return object.global_position.distance_to(P.global_position)


func interact():
	reticle_pressed_show()
	activate_item()


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
	
	trigger_beat_check()
	object.activate()


func reticle_pressed_show():
	if not is_instance_valid(reticle):
		return
	
	animating_reticle_pressed = true
	reticle.texture = RETICLE_PRESSED
	await get_tree().create_timer(0.15).timeout
	reticle.texture = RETICLE
	animating_reticle_pressed = false
