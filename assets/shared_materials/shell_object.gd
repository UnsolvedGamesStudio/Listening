extends RigidBody3D
class_name ShellObject
## Todo: work with the player's damage angle detection for special cases
## Todo: shader on the break texture to make it grow naturally
## Todo: emit particles when broken
## Todo: let it work from outside the ability usage, or maybe extra shield is more fun
## Todo: Try converting break texture to a decal
@onready var timer: Timer = $Timer
@onready var mesh_instance_3d: MeshInstance3D = %MeshInstance3D
@onready var area_3d: Area3D = %Area3D
@onready var broken_sfx: AudioStreamPlayer3D = %BrokenSFX
@onready var created_sfx: AudioStreamPlayer3D = %CreatedSFX
@onready var break_particles: CPUParticles3D = %BreakParticles

var ability: Node
var finished_appearing:= false
var lerp_weight:= 0.1
var no_follow_time:= 0.5
var halt_follow:= false

var max_hp:= 75.0:
	set(value):
		max_hp = clampf(value, 1.0, 9999.9)

var hp:= max_hp:
	set(value):
		hp = clampf(value, 0.0, max_hp)


func _ready() -> void:
	var player: Node3D = get_tree().get_first_node_in_group("player")
	mesh_instance_3d.get_active_material(0).next_pass.next_pass.uv1_scale = Vector3(500.0, 500.0, 500.0)
	body_entered.connect(on_body_entered)
	area_3d.area_entered.connect(on_area_3d_area_entered)
	created_sfx.play()


func _physics_process(delta: float) -> void:
	var player: Node3D = get_tree().get_first_node_in_group("player")
	var camera: Camera3D = player.camera
	global_rotation.x = lerp_angle(global_rotation.x, camera.global_rotation.x / 2, lerp_weight)
	global_rotation.y = lerp_angle(global_rotation.y, camera.global_rotation.y, lerp_weight)
	global_rotation.z = lerp_angle(global_rotation.z, camera.global_rotation.z, lerp_weight)
	
	if halt_follow == true:
		return
	
	global_position = lerp(global_position, player.global_position, lerp_weight * 2)
	
	if finished_appearing == false:
		return
	
	if not player.scale == Vector3.ONE:
		scale = lerp(scale, player.scale, lerp_weight)


func delay_physics():
	if halt_follow == true:
		return
	
	timer.start(no_follow_time)
	halt_follow = true
	await timer.timeout
	halt_follow = false


func take_damage(amount: float):
	hp -= amount
	update_break_state()
	if hp <= 0:
		if not ability == null:
			ability.active_shell = null
			ability.active = false
		
		destroy()


func update_break_state():
	if hp > max_hp * 0.9:
		mesh_instance_3d.get_active_material(0).next_pass.next_pass.uv1_scale = Vector3(500.0, 500.0, 500.0)
		return
	
	var hp_to_scale:= hp / max_hp * 5.5
	mesh_instance_3d.get_active_material(0).next_pass.next_pass.uv1_scale = Vector3(hp_to_scale, hp_to_scale, hp_to_scale)


func destroy():
	broken_sfx.play()
	break_particles.reparent(Find.layout())
	break_particles.activate()
	queue_free()


func heal(amount: float):
	hp += amount
	update_break_state()


func on_body_entered(body):
	delay_physics()


func on_area_3d_area_entered(area: Area3D):
	if area.owner is EnemyProjectile:
		take_damage(area.owner.damage)
