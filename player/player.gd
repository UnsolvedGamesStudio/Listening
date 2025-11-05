extends Node3D
class_name Player
## Todo: Add indicator of effective range, maybe a line with a ball at the end?
## Todo: Add signals for "successful actions", so you can't cheese the score as much?
## Todo: Figure out discolored pixels on sprite3d and mesh
## Todo: Consumable items (scroll to select, right click to use)
## Todo: Different effects based on spell combos
## Todo: Add instruments with different buffs and samples
## Todo: Add equipable accessories with buffs
## Todo: Fast travel spots
## Todo: MAYBE make all player actions work no matter what, but improve them if successful, or have it be a toggle for now
const MOVE_SIGIL = preload("uid://iw7wpmqsi86")

@onready var camera: Camera3D = %Camera3D
@onready var neck: Node3D = %Neck
@onready var player_collision: Area3D = %PlayerCollision
@onready var enemy_aim_point: Marker3D = %EnemyAimPoint
@onready var headbob: AnimationPlayer = %Headbob
@onready var movement_raycast: RayCast3D = %MovementRaycast
@onready var los: RayCast3D = %LineOfSight
@onready var move_to_cell_indicator: Node3D = %MoveToCellIndicator

@export var camera_raycast_distance:= 200.0
@export var interact_range: float = 1.0
@export var camera_speed:= 50
@export var spawn_pos:= Vector3(0, 0, 0)

var tilt_lower_limit:= deg_to_rad(-90)
var tilt_upper_limit:= deg_to_rad(90)

var looked_at_cell: Cell
var looked_at_object: Area3D
var is_moving:= false

var invincible_cheat:= false
var invincible:= false
var can_act:= true

## Stats
const base_max_hp:= 250.0
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
	movement_raycast.target_position.z = -Vars.cell_size / 1.75
	interact_range = Vars.cell_size * 10000
	los.global_position = camera.global_position
	await get_tree().create_timer(0.0).timeout
	
	move_to_cell_indicator.reparent(get_parent())
	movement_raycast.reparent(get_parent())
	go_to_spawn()
	player_collision.get_child(0).disabled = false
	update_looked_at_cell()
	Bus.player_moved.emit()
	lose_hp(75.0)

## Todo: choose randomly from all spawn points
func go_to_spawn():
	var spawn_point:= get_tree().get_first_node_in_group("player_spawn")

	if spawn_point == null:
		printerr(self, ": player spawn not set")
		return
	
	global_position = spawn_point.global_position


func reset_vars():
	invincible = false
	can_act = true
	looked_at_cell = null
	max_hp = base_max_hp
	hp = max_hp
	movement_speed = base_movement_speed


func _unhandled_input(event: InputEvent) -> void:
	var mouse_input = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	
	if mouse_input:
		camera_movement(event)
		update_looked_at_cell()


func _physics_process(delta: float) -> void:
	current_los_collider()


func _input(event: InputEvent) -> void:
	if can_act == false:
		return
	
	if event.is_action_pressed("forward") and is_moving == false:
		move_forward()


func camera_movement(event: InputEvent):
	if not Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		return
	
	if not event is InputEventMouseMotion:
		return
	
	neck.rotate_y(-event.relative.x * (camera_speed / 12000.0))
	camera.rotate_x(-event.relative.y * (camera_speed / 12000.0))
	player_collision.rotate_y(-event.relative.x * (camera_speed / 12000.0))
	camera.rotation.x = clampf(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


## Upside-down camera movement:
	#neck.rotate_y(event.relative.x * (camera_speed / 12000.0))
	#camera.rotate_x(-event.relative.y * (camera_speed / 12000.0))
	#player_collision.rotate_y(-event.relative.x * (camera_speed / 12000.0))
	#camera.rotation.x = clampf(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func take_damage(amount: float, origin: Node3D = null):
	notify_enemy_of_projectile(origin)
	
	if amount <= 0.0:
		return
	
	Bus.player_took_damage.emit(origin)
	lose_hp(amount)


func notify_enemy_of_projectile(origin: Node3D):
	if origin == null:
		return
	
	if not "origin_node" in origin:
		return
	
	if not origin.origin_node.has_signal("projectile_hit_player"):
		return
	
	origin.origin_node.projectile_hit_player.emit()


func lose_hp(amount: float):
	if invincible == true or invincible_cheat == true:
		return
	
	hp -= amount
	
	Bus.player_lost_hp.emit()
	
	if hp <= 0:
		die()


func die():
	can_act = false
	invincible = true
	Bus.game_lost.emit()


func heal(amount: float):
	hp += amount


func move_forward():
	if Bgm.check_accuracy() == "missed":
		return
	
	update_looked_at_cell()
	
	if looked_at_cell == null:
		return
	
	if check_impassable() == true:
		return
	
	var move_speed: float = Bgm.rhythm_notifier.bpm / (movement_speed * 100)
	
	if not Vars.last_activated_circle == null:
		Vars.last_activated_circle.texture = MOVE_SIGIL
	
	var tween:= get_tree().create_tween()
	tween.tween_property(self, "global_position", looked_at_cell.global_position, move_speed)
	
	tween.play()
	headbob.play("bob")
	is_moving = true
	tween.tween_callback(update_looked_at_cell)
	tween.tween_callback(set_moving_false)
	tween.tween_callback(Bus.player_moved.emit)


func check_impassable():
	for occupant in looked_at_cell.occupants:
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
	
	var cell: Area3D = check_movement_raycast()
	
	if not cell is CellCollision:
		return
	
	looked_at_cell = cell.get_parent()
	
	update_move_to_cell_indicator(cell)


func update_move_to_cell_indicator(cell: Area3D):
	if check_impassable() == true:
		return
	
	if cell == Vars.player_cell:
		return
	
	move_to_cell_indicator.global_position = cell.global_position
	move_to_cell_indicator.global_rotation_degrees.y = snapped(neck.global_rotation_degrees.y, 90)


func check_movement_raycast():
	if movement_raycast.get_collider() == null:
		return
	
	return movement_raycast.get_collider()


func current_los_collider():
	##!! middle of screen is dependent on the viewport scale settings
	var middle_of_screen = get_viewport().size / 4
	var origin:= camera.project_ray_origin(middle_of_screen)
	var target:= origin + camera.project_ray_normal(middle_of_screen) * interact_range
	
	los.target_position = target
	
	return los.get_collider()


func get_look_at_direction(distance: float = camera_raycast_distance):
	var middle_of_screen = get_viewport().size / 4
	return camera.project_ray_normal(middle_of_screen) * camera_raycast_distance


func get_hit_angles(attacker: Node3D) -> Vector2:
	# Vector from player to attacker
	var to_attacker = (attacker.global_position - global_position).normalized()
	
	# Camera basis vectors
	var cam_forward = -camera.global_transform.basis.z.normalized()
	var cam_right = camera.global_transform.basis.x.normalized()
	var cam_up = camera.global_transform.basis.y.normalized()

	# Project attack direction into camera space
	var x = to_attacker.dot(cam_right)     # right (+) / left (-)
	var y = to_attacker.dot(cam_up)        # up (+) / down (-)
	var z = to_attacker.dot(cam_forward)   # forward (+) / back (-)

	# Horizontal and vertical angles in radians
	var horizontal_angle = atan2(x, z)
	var vertical_angle = atan2(y, z)
	
	# Return as a Vector2(horizontal, vertical)
	return Vector2(horizontal_angle, vertical_angle)


func shrink(amount: float):
	var tween:= create_tween()
	var target_value: Vector3 = scale / amount
	tween.tween_property(self, "scale", target_value, 0.5)


func on_player_collision_area_entered(area: Area3D):
	if "damage" in area.owner:
		take_damage(area.owner.damage, area.owner)
	
	if "body_damage" in area.owner:
		take_damage(area.owner.body_damage, area.owner)
