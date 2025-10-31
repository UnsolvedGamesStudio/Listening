extends Node3D
## Todo: play a chord of the corresponding "key" when unlocking with or picking up keys
@onready var sprite_3d: Sprite3D = %Sprite3D
@onready var sprite_3d_2: Sprite3D = %Sprite3D2
@onready var area_3d: Area3D = %Area3D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var original_scale:= Vector3(1.0, 1.0, 1.0)
var required_item:= Vars.item_types.F_KEY

func _ready() -> void:
	original_scale = sprite_3d.scale


func _physics_process(delta: float) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		return
	
	if player.los.get_collider() == area_3d and global_position.distance_to(player.global_position) < Vars.interact_range:
		looked_at_by_player(true)
	else:
		looked_at_by_player(false)


func activate():
	if not has_item() == true:
		animation_player.play("shake")
		return
	
	open()
	Vars.inventory[required_item]["amount"] -= 1
	Bus.item_removed.emit(required_item)


func open():
	var O: Node3D = owner.owner
	area_3d.get_child(0).disabled = true
	O.impassable = false
	O.occupied_cell = null
	
	var tween:= create_tween()
	var original_y:= O.global_position.y
	
	tween.tween_property(O, "global_position:y", original_y + 0.4, Bgm.rhythm_notifier.beat_length / 3)
	tween.tween_property(O, "global_position:y", original_y - 4.1, Bgm.rhythm_notifier.beat_length * 3)
	tween.parallel().tween_property(O, "global_rotation_degrees", Vector3(randf_range(-360, 360), randf_range(-180, 180), randf_range(-360, 360)), Bgm.rhythm_notifier.beat_length * 7)
	tween.tween_callback(O.queue_free)


func has_item():
	for item: Vars.item_types in Vars.inventory:
		if item == required_item:
			return true
	
	return false


func looked_at_by_player(on: bool):
	if on == true:
		if has_item() == true:
			sprite_3d.modulate = Color(0.409, 0.84, 0.0, 1.0)
			sprite_3d_2.modulate = Color(0.409, 0.84, 0.0, 1.0)
		else:
			sprite_3d.modulate = Color(0.954, 0.001, 0.954)
			sprite_3d_2.modulate = Color(0.954, 0.001, 0.954)
		
		sprite_3d.scale = original_scale * 1.5
		sprite_3d_2.scale = original_scale * 1.5
	
	else:
		sprite_3d.modulate = Color(1.0, 1.0, 1.0, 1.0)
		sprite_3d_2.modulate = Color(1.0, 1.0, 1.0, 1.0)
		sprite_3d.scale = original_scale
		sprite_3d_2.scale = original_scale
