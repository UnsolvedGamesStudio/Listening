extends CharacterBody3D
class_name Projectile

const POP_TEXTURE = preload("uid://cyk5g3u4ymo2g")

@onready var sprite_3d: Sprite3D = %Sprite3D
@onready var body_detect: Area3D = %BodyDetect
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
var max_distance:= 10.0
var produce_destroyed_fx:= true
var linger_time:= 0.08
var destroyed_fx:= preload("uid://dotmsm333w37o")

var starting_position:= Vector3.ZERO
var distance_traveled:= 0.0


func _ready() -> void:
	body_detect.area_entered.connect(on_body_detect_area_entered)
	sprite_3d.modulate = color
	starting_position = origin_node.global_position


func _physics_process(delta: float) -> void:
	direction = global_position.direction_to(target_point)
	velocity += direction * speed * delta
	distance_traveled = starting_position.distance_to(global_position)
	if distance_traveled >= max(2.5, max_distance):
		destroy()
	
	move_and_slide()


func destroy():
	if destroyed == true:
		return
	
	destroyed = true
	kill_timer.start(linger_time)
	target_point = global_position
	direction = global_position
	velocity = Vector3.ZERO
	
	spawn_destroyed_fx()
	
	await kill_timer.timeout
	
	sprite_3d.hide()
	hitbox.get_child(0).disabled = true
	body_detect.get_child(0).disabled = true
	kill_timer.start(5.0)
	await kill_timer.timeout
	queue_free()


func spawn_destroyed_fx():
	if produce_destroyed_fx == false:
		return
	
	var pop:= destroyed_fx.instantiate()
	pop.texture = POP_TEXTURE
	pop.modulate.a = 0.5
	get_parent().add_child(pop)
	pop.scale *= 2.0
	pop.global_position = global_position


func on_body_detect_area_entered(area: Area3D):
	if not origin_node == null:
		if not "owner" in area:
			return
	
		if area.owner == origin_node:
			return
	destroy()
