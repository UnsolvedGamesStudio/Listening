extends Node

const INTERACT_SIGIL = preload("uid://b0tw8jr20jhhj")
const RETICLE = preload("uid://b7mmj4bh7r1aa")
const RETICLE_PRESSED = preload("uid://cvx1igefaxkfg")

var reticle: TextureRect


func _ready() -> void:
	reticle = get_tree().get_first_node_in_group("reticle")


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	
	interact()


func interact():
	var success = Bgm.check_accuracy()
	
	if success == "missed":
		return
	
	change_reticle_texture()
	if not Vars.last_activated_circle == null:
		Vars.last_activated_circle.texture = INTERACT_SIGIL


func change_reticle_texture():
	if reticle == null:
		printerr(self, ": reticle not found.")
		return
	
	reticle.texture = RETICLE_PRESSED
	await get_tree().create_timer(0.15).timeout
	reticle.texture = RETICLE
