extends Node3D
class_name Player
## Todo: Make headbob anim a tween with adaptive speed
## Todo: Add indicator of effective range, maybe a line with a ball at the end?
## Todo: Add signals for "successful actions", so you can't cheese the score as much?
## Todo: Make held instrument go up when camera goes way down
## Todo: Make an enum+dict that stores all the actions the player can take, and whether they are enabled
## Todo: Consolidate what should be in here or Vars
@onready var camera: Camera3D = %Camera3D
@onready var neck: Node3D = %Neck
@onready var player_collision: Area3D = %PlayerCollision
@onready var enemy_aim_point: Marker3D = %EnemyAimPoint
@onready var headbob: AnimationPlayer = %Headbob
@onready var movement_raycast: RayCast3D = %MovementRaycast
@onready var los: RayCast3D = %LineOfSight
@onready var move_to_cell_indicator: Node3D = %MoveToCellIndicator
@onready var abilities: Node = %Abilities
@onready var player_sfx: Node = $PlayerSFX
@onready var heal_particles: GPUParticles3D = %HealParticles

const MOVE_SIGIL = preload("uid://iw7wpmqsi86")

@export var camera_raycast_distance:= 200.0
@export var interact_range: float = 1.0
@export var camera_speed:= 50

var tilt_lower_limit:= deg_to_rad(-90)
var tilt_upper_limit:= deg_to_rad(90)

var looked_at_cell: Cell
var looked_at_object: Area3D
var is_moving:= false

var invincible_cheat:= false
var invincible:= false
var can_act:= true
var can_interact:= true

## Stats
var max_hp:= 250.0:
	set(value):
		max_hp = clampf(value, 1.0, 9999.9)

var hp:= max_hp:
	set(value):
		hp = clampf(value, 0.0, max_hp)

var movement_speed:= 2.5:
	set(value):
		movement_speed = clampf(value, 1.0, 4.0)

var damage_mult:= 1.0:
	set(value):
		damage_mult = clampf(value, 0.1, 5.0)

var damage:= 20.0:
	set(value):
		damage = clampf(value, 1.0, 1000.0)

var is_on_web_os:= false


func _ready() -> void:
	if OS.get_name() == "Web":
		is_on_web_os = true
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	reset_vars()
	player_collision.area_entered.connect(on_player_collision_area_entered)
	movement_raycast.target_position.z = -Vars.cell_size / 1.75
	interact_range = Vars.cell_size * 10000
	los.global_position = camera.global_position
	
	await Bus.level_layout_ready
	
	move_to_cell_indicator.reparent(get_parent())
	movement_raycast.reparent(get_parent())
	go_to_spawn()
	player_collision.get_child(0).disabled = false
	Bus.player_moved.emit()


func go_to_spawn():
	var spawn_point:= get_tree().get_first_node_in_group("player_spawn")

	if spawn_point == null:
		push_error(self, ": player spawn not set")
		return
	
	global_position = spawn_point.global_position
	global_rotation = spawn_point.global_rotation


func reset_vars():
	invincible = false
	can_act = true
	looked_at_cell = null
	hp = max_hp
	Vars.dopamine = Vars.max_dopamine / 2.0


func _unhandled_input(event: InputEvent) -> void:
	var mouse_input = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	
	if mouse_input:
		camera_movement(event)
		update_move_to_cell_indicator()


func _physics_process(delta: float) -> void:
	current_los_collider()
	snap_rotations()
	if Input.is_action_pressed("forward") and can_act == true:
		move_forward()
	
	if Input.is_action_just_pressed("forward") and can_act == true and is_moving == false:
		Bus.beat_press_attempted.emit()
	
	if is_moving == true and player_sfx.steps.is_playing() == false:
		player_sfx.steps.pitch_scale = randf_range(0.9, 1.1)
		player_sfx.steps.play()
	
	if is_moving == false:
		player_sfx.steps.stop()


func snap_rotations():
	movement_raycast.global_rotation_degrees.y = snappedf(neck.global_rotation_degrees.y, 90)


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
	player_sfx.heal.play()
	heal_particles.emitting = true
	await get_tree().create_timer(1.0).timeout
	heal_particles.emitting = false


func move_forward():
	if is_moving == true:
		return
	
	var target_cell: Node3D = get_looked_at_cell()
	
	if target_cell == null:
		return
	
	if check_impassable(target_cell) == true:
		return
	
	is_moving = true
	trigger_beat_check()
	
	var tween_length: float = (Bgm.rhythm_notifier.beat_length * 1.8) / (movement_speed)
	var tween:= get_tree().create_tween()
	
	tween.tween_property(self, "global_position", target_cell.global_position, tween_length)
	headbob.play("bob")
	
	await tween.finished
	
	Bus.player_moved.emit()
	is_moving = false
	update_move_to_cell_indicator()


func trigger_beat_check():
	if not Input.is_action_just_pressed("forward"):
		return
	
	Bgm.check_accuracy()
	
	if not Vars.last_activated_circle == null:
		Vars.last_activated_circle.change_texure(MOVE_SIGIL)


func check_impassable(cell: Node3D):
	if cell == null:
		return
	
	for occupant in cell.occupants:
		if not is_instance_valid(occupant):
			return false
		
		if not "impassable" in occupant:
			return false
		
		if occupant.impassable == true:
			return true
	
	return false


func update_move_to_cell_indicator():
	if is_moving == true:
		return
	
	var target_cell: Node3D = get_looked_at_cell()
	
	if target_cell == null:
		move_to_cell_indicator.hide()
		return
	
	if check_impassable(target_cell) == true:
		move_to_cell_indicator.hide()
		return
	
	if move_to_cell_indicator.visible == false:
		move_to_cell_indicator.show()
	
	move_to_cell_indicator.global_position = target_cell.global_position
	move_to_cell_indicator.global_rotation_degrees.y = movement_raycast.global_rotation_degrees.y


func get_looked_at_cell():
	var collider: Area3D = movement_raycast.get_collider()
	
	if collider == null:
		return
	
	if not collider is CellCollision:
		return
	
	if not collider.owner is Cell:
		return
	
	var cell:= collider.owner
	
	if "max_player_height" in cell:
		if scale.y > collider.owner.max_player_height:
			return
	
	return cell


func current_los_collider():
	var middle_of_screen = get_viewport().get_visible_rect().size / 2
	var origin:= camera.project_ray_origin(middle_of_screen)
	var target:= origin + camera.project_ray_normal(middle_of_screen) * interact_range
	
	los.target_position = target
	
	return los.get_collider()


func get_look_at_direction(distance: float = camera_raycast_distance):
	var middle_of_screen = get_viewport().get_visible_rect().size / 2
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
	interact_range *= amount


func on_player_collision_area_entered(area: Area3D):
	if "damage" in area.owner:
		take_damage(area.owner.damage, area.owner)
	
	if "body_damage" in area.owner:
		take_damage(area.owner.body_damage, area.owner)
