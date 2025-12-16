extends Node3D
class_name Keyhole
## Todo: Play a chord of the corresponding "key" when unlocking with or picking up keys
##Todo: Extend the walls of the locked wall if adjacent walls are detected/remove other walls
@onready var decal: Decal = %Decal
@onready var area_3d: Area3D = %Area3D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var unlock_sfx: AudioStreamPlayer3D = %UnlockSFX
@onready var locked_sfx: AudioStreamPlayer3D = %LockedSFX

var original_scale:= Vector3(1.0, 1.0, 1.0)
var required_item:= Vars.item_types.F_KEY


func _ready() -> void:
	original_scale = decal.scale


func _physics_process(delta: float) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		return
	
	if player.los.get_collider() == area_3d and global_position.distance_to(player.global_position) < Vars.interact_range:
		looked_at_by_player(true)
	else:
		looked_at_by_player(false)


func activate():
	if has_item() == false:
		animation_player.play("shake")
		locked_sfx.play()
		return
	
	open()
	Vars.inventory[required_item]["amount"] -= 1
	Bus.item_removed.emit(required_item)


func open():
	var O: Node3D = owner.owner
	
	area_3d.get_child(0).disabled = true
	O.impassable = false
	O.occupied_cell = null
	unlock_sfx.play(0.35)
	
	var tween:= create_tween()
	var original_y:= O.global_position.y
	
	tween.tween_property(O, "global_position:y", original_y + 0.4, Bgm.rhythm_notifier.beat_length / 3)
	tween.tween_property(O, "global_position:y", original_y - 4.1, Bgm.rhythm_notifier.beat_length * 3)
	tween.parallel().tween_property(O, "global_rotation_degrees", Vector3(randf_range(-360, 360), randf_range(-180, 180), randf_range(-360, 360)), Bgm.rhythm_notifier.beat_length * 7)
	tween.tween_callback(O.queue_free)


func has_item():
	for item: Vars.item_types in Vars.inventory:
		if item == required_item:
			if Vars.inventory[required_item]["amount"] > 0:
				return true
	
	return false


func looked_at_by_player(on: bool):
	if on:
		if has_item() == true:
			decal.modulate = Color(0.0, 0.924, 0.94)
		else:
			decal.modulate = Color(0.68, 0.256, 0.15, 1.0)
		
		decal.scale = original_scale * 1.25
	
	else:
		decal.modulate = Color(1.0, 1.0, 1.0, 1.0)
		decal.scale = original_scale
