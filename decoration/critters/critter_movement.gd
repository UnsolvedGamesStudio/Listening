extends CritterBehavior

@onready var direction_timer: Timer = %DirectionTimer
@onready var speed_boost_timer: Timer = %SpeedBoostTimer

@export var min_random_time:= 2.0
@export var max_random_time:= 5.0
@export var turn_speed:= 4.0
@export var base_speed:= 1.0
@export var speed_boost_frequency:= 4.0
@export_range(0.0, 1.0) var speed_boost_chance:= 0.5
@export var speed_boost_mult:= 2.0

var speed:= base_speed
var direction:= Vector3(-1.0, 0.0, 0.0)
var target_direction:= Vector3.ZERO


func level_ready():
	O.wall_detect.body_entered.connect(on_wall_detect_body_entered)
	direction_timer.timeout.connect(on_direction_timer_timeout)
	speed_boost_timer.timeout.connect(on_speed_boost_timer_timeout)
	
	randomize_direction()


func p_process(delta: float):
	if O.dead == true:
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	
	move(delta)
	curve_direction(delta)
	face_direction()


func face_direction():
	if direction.length() < 0.001:
		return
	
	O.look_at(O.global_position + direction)


func move(delta):
	var move_force: Vector3 = direction * speed * delta
	O.move_and_collide(move_force)


func curve_direction(delta):
	direction = direction.slerp(target_direction, delta * turn_speed)


func randomize_direction():
	var angle:= randf_range(0.0, TAU)
	target_direction = Vector3(cos(angle), 0.0, sin(angle) )


func reverse_direction():
	var random_turn:= randf_range(-PI/2, PI/2)
	var current_angle:= atan2(direction.z, direction.x)
	var new_angle:= current_angle + PI + random_turn
	
	target_direction = Vector3(cos(new_angle), 0.0, sin(new_angle))


func random_speed_boost():
	if randf() < speed_boost_chance:
		speed *= speed_boost_mult


func animate():
	if not "animation_player" in O:
		return
	
	if abs(O.linear_velocity.length()) == 0.01:
		pass ## play idle
	
	elif O.animation_player.playing == false:
		pass ## play move


func on_wall_detect_body_entered(body: Node3D):
	reverse_direction()


func on_direction_timer_timeout():
	direction_timer.start(randf_range(min_random_time, max_random_time) )
	
	random_speed_boost()
	randomize_direction()


func on_speed_boost_timer_timeout():
	speed_boost_timer.start(speed_boost_frequency * randf_range(0.8, 1.2) )
	speed = base_speed
	
	random_speed_boost()
