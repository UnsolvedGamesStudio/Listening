extends Node

@onready var label: Label = $Label

const CAST_SIGIL = preload("uid://c5nwti415vrqj")
const EMPTY_CAST_SIGIL = preload("uid://cquqsopjsxe0b")
const DEFAULT_SPELL = preload("uid://d0jjxcbead86g")

const PROJECTILE = preload("uid://bwaev5gyis5tp")

@export var spell_range:= 7.0

var element_expiry_time_mult:= 20.0
var container:= Vars.element_container
var container_ui: ElementContainerUI
var player: Player


func _ready() -> void:
	container_ui = get_tree().get_first_node_in_group("element_container_ui")
	player = owner


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cast"):
		on_cast_pressed()
	
	if event.is_action_pressed("element_1"):
		add_element(0)
	
	if event.is_action_pressed("element_2"):
		add_element(1)
	
	if event.is_action_pressed("element_3"):
		add_element(2)


func on_cast_pressed():
	var success: String = Bgm.check_accuracy()
	
	if success == "missed":
		return
	
	cast_spell()


func add_element(element: int):
	var success: String = Bgm.check_accuracy()
	
	if success == "missed":
		return
	
	if not Vars.last_activated_circle == null:
		Vars.last_activated_circle.texture = Vars.elements[element].texture
	
	element_expiry()
	
	if container.size() >= 3:
		container.push_front(element)
	else:
		container.append(element)
	
	container_ui.update()


func cast_spell():
	Bgm.play_midi()
	if container == []:
		if not Vars.last_activated_circle == null:
			Vars.last_activated_circle.texture = EMPTY_CAST_SIGIL
		return
	
	if not Vars.last_activated_circle == null:
		Vars.last_activated_circle.texture = CAST_SIGIL
	
	create_projectile()
	container.clear()
	container_ui.update()


func create_projectile():
	var projectile_inst: Projectile = PROJECTILE.instantiate()
	var position_offset:= 0.15
	var look_at_direction: Vector3 = player.get_look_at_direction()
	
	projectile_inst.color = determine_color()
	projectile_inst.damage = determine_damage()
	projectile_inst.player = player
	projectile_inst.target_point = look_at_direction
	projectile_inst.origin_node = player
	projectile_inst.max_distance = spell_range
	
	owner.get_parent().add_child(projectile_inst)
	
	projectile_inst.sprite_3d.texture = DEFAULT_SPELL
	projectile_inst.hitbox.set_collision_layer_value(5, true)
	projectile_inst.global_position.x = player.camera.global_position.x + (position_offset * (look_at_direction.x / 50))
	projectile_inst.global_position.y = player.camera.global_position.y + (position_offset * (look_at_direction.y / 50))
	projectile_inst.global_position.z = player.camera.global_position.z  + (position_offset * (look_at_direction.z / 50))


func element_expiry():
	container_ui.element_expiry_timer.start(Bgm.rhythm_notifier.beat_length * element_expiry_time_mult)
	await container_ui.element_expiry_timer.timeout
	Vars.element_container.clear()
	container_ui.update()


func determine_damage():
	var damage:= 0.0
	
	damage += (20 * Vars.element_container.size() ) + (Vars.score / 10)
	
	return damage


func determine_color():
	var color:= Color.WHITE
	
	for element in Vars.element_container:
		if not "id" in Vars.elements[element]:
			return
		
		if Vars.elements[element].id == "joy":
			color.b -= 0.3
		
		if Vars.elements[element].id == "sadness":
			color.r -= 0.15
			color.g -= 0.15
		
		if Vars.elements[element].id == "anger":
			color.b -= 0.15
			color.g -= 0.15
	
	return color
