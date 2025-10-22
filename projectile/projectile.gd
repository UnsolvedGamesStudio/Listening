extends CharacterBody3D
class_name Projectile

const POP_TEXTURE = preload("uid://cyk5g3u4ymo2g")
const SPRITE_EFFECT = preload("uid://dotmsm333w37o")

@onready var sprite_3d: Sprite3D = %Sprite3D
@onready var hitbox: Area3D = %Hitbox
@onready var kill_timer: Timer = %KillTimer

var destroyed:= false

var origin_node: Node3D
var target_point:= Vector3.ZERO
var direction:= Vector3.ZERO
var player: Player
var color:= Color.WHITE

var speed:= 60.0
var damage:= 50.0
var max_distance:= 4.0

var starting_position:= Vector3.ZERO
var distance_traveled:= 0.0


func _ready() -> void:
	hitbox.area_entered.connect(on_hitbox_area_entered)
	sprite_3d.modulate = color
	starting_position = player.global_position


func _physics_process(delta: float) -> void:
	direction = global_position.direction_to(target_point)
	velocity += direction * speed * delta
	
	distance_traveled = starting_position.distance_to(global_position)
	if distance_traveled >= max(2.5, max_distance):
		destroy()
	
	move_and_slide()


func on_hitbox_area_entered(area: Area3D):
	if not origin_node == null:
		if not "owner" in area:
			return
	
		if area.owner == origin_node:
			return
	destroy()


func destroy():
	if destroyed == true:
		return
	
	destroyed = true
	kill_timer.start(0.08)
	
	var pop:= SPRITE_EFFECT.instantiate()
	pop.texture = POP_TEXTURE
	get_parent().add_child(pop)
	pop.scale *= 2.0
	pop.global_position = global_position
	
	await kill_timer.timeout
	sprite_3d.hide()
	hitbox.get_child(0).disabled = true
	kill_timer.start(3.0)
	await kill_timer.timeout
	queue_free()
