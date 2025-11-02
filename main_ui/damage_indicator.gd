extends TextureRect
class_name DamageIndicator

@onready var animation_player: AnimationPlayer = %AnimationPlayer

var a:= -1.5
var b:= -2.3
var c:= -3.0
var d:= 2.3
var e:= 1.4
var f:= 0.7
var g:= 0.0
var h:= -0.7

var leeway:= 0.01


func _ready() -> void:
	Bus.player_took_damage.connect(on_player_took_damage)


func on_player_took_damage(origin: Node3D = null):
	if origin == null:
		return
	
	var player: Player = get_tree().get_first_node_in_group("player")
	animation_player.play(get_hit_direction(player, origin, player.camera))


func get_hit_direction(player: Node3D, attacker: Node3D, camera: Camera3D) -> String:
	# Vector from player to attacker, ignore vertical
	var to_attacker = (attacker.global_position - player.global_position)
	to_attacker.y = 0
	
	if to_attacker.length_squared() == 0:
		if attacker.global_position.y > (camera.global_position.y):
			return "up"
		else:
			return "down"
	
	to_attacker = to_attacker.normalized()
	
	# Camera horizontal forward
	var forward = -camera.global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()
	
	# Compute right using cross product (always consistent)
	var right = forward.cross(Vector3.UP).normalized()

	# Compute horizontal angle
	var x = to_attacker.dot(right)
	var z = to_attacker.dot(forward)
	var angle = atan2(x, z)  # radians, 0 = front, +left, -right
	var angle_deg = rad_to_deg(angle)

	# Normalize [-180, 180)
	if angle_deg > 180:
		angle_deg -= 360
	elif angle_deg < -180:
		angle_deg += 360

	# 8-way horizontal classification
	if abs(angle_deg) <= 22.5:
		return "up"
	elif angle_deg > 22.5 and angle_deg <= 67.5:
		return "right_up"
	elif angle_deg > 67.5 and angle_deg <= 112.5:
		return "right"
	elif angle_deg > 112.5 and angle_deg <= 157.5:
		return "right_down"
	elif abs(angle_deg) > 157.5:
		return "down"
	elif angle_deg < -22.5 and angle_deg >= -67.5:
		return "left_up"
	elif angle_deg < -67.5 and angle_deg >= -112.5:
		return "left"
	elif angle_deg < -112.5 and angle_deg >= -157.5:
		return "left_down"
	else:
		return "unknown"
