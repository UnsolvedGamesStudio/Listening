extends Node3D
class_name Player
## Todo: add indicator of effective range, probably a line with a ball at the end?
const MOVE_SIGIL = preload("uid://iw7wpmqsi86")

@onready var camera: Camera3D = %Camera3D
@onready var neck: Node3D = %Neck
@onready var player_collision: Area3D = %PlayerCollision
@onready var enemy_aim_point: Marker3D = %EnemyAimPoint
@onready var headbob: AnimationPlayer = %Headbob

@export var camera_raycast_distance:= 200.0
@export var camera_speed:= 50
@export var spawn_pos:= Vector3(0, 0, 0)

var tilt_lower_limit:= deg_to_rad(-90)
var tilt_upper_limit:= deg_to_rad(90)

var current_looked_at_cell: Cell
var is_moving:= false

var invincible_cheat:= false
var invincible:= false

## Stats
const base_max_hp:= 200.0
var max_hp:= base_max_hp:
	set(value):
		max_hp = clampf(value, 1.0, 9999.9)

var hp:= max_hp:
	set(value):
		hp = clampf(value, 0.0, max_hp)

const base_movement_speed:= 4
var movement_speed:= 20:
	set(value):
		movement_speed = clampi(value, 1, 20)


func _ready() -> void:
	reset_vars()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	position = spawn_pos
	player_collision.area_entered.connect(on_player_collision_area_entered)
	
	await get_tree().create_timer(0.0).timeout
	
	global_position = get_tree().get_first_node_in_group("player_spawn").global_position
	update_looked_at_cell()
	Bus.player_moved.emit()


func reset_vars():
	current_looked_at_cell = null
	max_hp = base_max_hp
	hp = max_hp
	movement_speed = base_movement_speed
	Bus.player_hp_changed.emit()


func _unhandled_input(event: InputEvent) -> void:
	var mouse_input = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	
	if mouse_input:
		camera_movement(event)
		update_looked_at_cell()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("forward") and is_moving == false:
		move_forward()


func camera_movement(event: InputEvent):
	if not Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		return
	
	if not event is InputEventMouseMotion:
		return
	
	neck.rotate_y(-event.relative.x * (camera_speed / 12000.0))
	camera.rotate_x(-event.relative.y * (camera_speed / 12000.0))
	camera.rotation.x = clampf(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func take_damage(amount: float):
	if invincible == true or invincible_cheat == true:
		return
	
	hp -= amount
	
	Bus.player_lost_hp.emit()
	Bus.player_hp_changed.emit()
	
	if hp <= 0:
		die()


func die():
	SceneManager.reload_game()


func move_forward():
	if Bgm.check_accuracy() == "missed":
		return
	
	update_looked_at_cell()
	
	if current_looked_at_cell == null:
		return
	
	if impassable_enemy() == true:
		return
	
	var move_speed: float = Bgm.rhythm_notifier.bpm / (movement_speed * 100)
	
	if not Vars.last_activated_circle == null:
		Vars.last_activated_circle.texture = MOVE_SIGIL
	
	var tween:= get_tree().create_tween()
	tween.tween_property(self, "global_position", current_looked_at_cell.global_position, move_speed)
	
	tween.play()
	headbob.play("bob")
	is_moving = true
	tween.tween_callback(update_looked_at_cell)
	tween.tween_callback(set_moving_false)
	tween.tween_callback(Bus.player_moved.emit)


func impassable_enemy():
	for occupant in current_looked_at_cell.occupants:
		if not is_instance_valid(occupant):
			return false
		
		if not "impassable" in occupant:
			return false
		
		if occupant.impassable == true:
			return true
	
	return false


func set_moving_false():
	is_moving = false


func update_looked_at_cell():
	var cell: Area3D = check_raycast_cells()
	var move_to_cell_indicator = get_tree().get_first_node_in_group("move_to_cell_indicator")

	if not cell is CellCollision:
		return
	
	current_looked_at_cell = cell.get_parent()
	
	move_to_cell_indicator.global_position = cell.global_position
	move_to_cell_indicator.global_rotation_degrees.y = snapped(neck.global_rotation_degrees.y, 90)


func check_raycast_cells():
	var space_state:= camera.get_world_3d().direct_space_state
	##!! middle of screen is dependent on the viewport scale settings
	var middle_of_screen = get_viewport().size / 4
	var origin:= camera.project_ray_origin(middle_of_screen)
	var end:= origin + camera.project_ray_normal(middle_of_screen) * camera_raycast_distance
	var query:= PhysicsRayQueryParameters3D.create(origin, end)
	
	query.collide_with_areas = true
	
	var result:= space_state.intersect_ray(query)
	
	if not "collider" in result:
		return
		
	return result["collider"]


func get_look_at_direction():
	var middle_of_screen = get_viewport().size / 4
	return camera.project_ray_normal(middle_of_screen) * camera_raycast_distance


func on_player_collision_area_entered(area: Area3D):
	if "damage" in area.owner:
		take_damage(area.owner.damage)
	
	if "body_damage" in area.owner:
		take_damage(area.owner.body_damage)
