extends Node3D
class_name Player

@onready var camera: Camera3D = %Camera3D
@onready var neck: Node3D = %Neck

const MOVE_SIGIL = preload("uid://iw7wpmqsi86")

@export var camera_raycast_distance:= 200.0
@export var camera_speed:= 50
@export var spawn_pos:= Vector3(0, 0, 0)
@export_range(1, 3) var move_speed_level:= 2

var move_to_cell_indicator: Node3D

var tilt_lower_limit:= deg_to_rad(-90)
var tilt_upper_limit:= deg_to_rad(90)

var current_looked_at_cell: Cell
var is_moving:= false


func _ready() -> void:
	position = spawn_pos
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	move_to_cell_indicator = get_tree().get_first_node_in_group("move_to_cell_indicator")
	
	await get_tree().create_timer(0.0).timeout
	update_looked_at_cell()


func _unhandled_input(event: InputEvent) -> void:
	var mouse_input = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	
	if mouse_input:
		camera_movement(event)
		update_looked_at_cell()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("forward") and is_moving == false:
		move_forward()
	
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func camera_movement(event: InputEvent):
	if not Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		return
	
	if not event is InputEventMouseMotion:
		return
	
	neck.rotate_y(-event.relative.x * (camera_speed / 12000.0))
	camera.rotate_x(-event.relative.y * (camera_speed / 12000.0))
	camera.rotation.x = clampf(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func move_forward():
	if Bgm.check_accuracy() == "missed":
		return
	
	update_looked_at_cell()
	
	if current_looked_at_cell == null:
		return
	
	var move_speed: float
	if move_speed_level == 1:
		move_speed = Bgm.rhythm_notifier.bpm / 200
	if move_speed_level == 2:
		move_speed = Bgm.rhythm_notifier.bpm / 400
	if move_speed_level == 3:
		move_speed = Bgm.rhythm_notifier.bpm / 800
	
	if not Vars.last_activated_circle == null:
		Vars.last_activated_circle.texture = MOVE_SIGIL
	
	var tween:= get_tree().create_tween()
	tween.tween_property(self, "global_position", current_looked_at_cell.global_position, move_speed)
	
	tween.play()
	is_moving = true
	tween.tween_callback(update_looked_at_cell)
	tween.tween_callback(set_moving_false)
	tween.tween_callback(update_occupied_cell)


func update_occupied_cell():
	Vars.occupied_cell = current_looked_at_cell
	current_looked_at_cell = null
	print(Vars.occupied_cell)


func set_moving_false():
	is_moving = false


func update_looked_at_cell():
	var cell: Area3D = check_raycast(true)
	
	if not cell is CellCollision:
		return
	
	current_looked_at_cell = cell.get_parent()
	
	move_to_cell_indicator.global_position = cell.global_position
	move_to_cell_indicator.global_rotation_degrees.y = snapped(neck.global_rotation_degrees.y, 90)


func check_raycast(collider: bool = false):
	var space_state:= camera.get_world_3d().direct_space_state
	##!! middle of screen is dependent on the viewport scale settings
	var middle_of_screen = get_viewport().size / 4
	var origin:= camera.project_ray_origin(middle_of_screen)
	var end:= origin + camera.project_ray_normal(middle_of_screen) * camera_raycast_distance
	var query:= PhysicsRayQueryParameters3D.create(origin, end)
	
	if collider == true:
		query.collide_with_areas = true
	
	var result:= space_state.intersect_ray(query)
	
	if collider == true:
		if not "collider" in result:
			return
		
		return result["collider"]
	
	else:
		return result


func get_look_at_direction():
	var middle_of_screen = get_viewport().size / 4
	return camera.project_ray_normal(middle_of_screen) * camera_raycast_distance
