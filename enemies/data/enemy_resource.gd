extends Resource
class_name EnemyResource

@export_category("Info")
@export var id:= "id"
@export var name:= "Name"
@export var description:= "Description"

@export_category("AI")
@export var preferred_range: ranges
enum ranges{MELEE, RANGED, CONTACT}
@export var vision_limit:= 10.0

@export var behaviors: Array[NodePath] = [
	"res://enemies/behaviors/get_hurt_eb.tscn",
	"res://enemies/behaviors/movement_eb.tscn",
	"res://enemies/behaviors/ranged_attack_eb.tscn",
	"res://enemies/behaviors/melee_attack_eb.tscn",
]

@export_category("Stats")
@export var max_hp:= 100.0
@export var movement_speed:= 4
@export var impassable:= false
@export var body_damage:= 10.0
@export var counts_towards_goal:= true

@export_category("Timings")
@export var moves_every_x_beat:= 4
@export var melees_every_x_beat:= 4
@export var shoots_every_x_beat:= 6

@export_category("Melee")
@export var melee_range:= 1
@export var melee_damage:= 20.0

@export_category("Projectile")
@export var projectile_enabled:= true
@export var projectile_texture:= preload("uid://dgygswxu7j8ds")
@export var projectile_damage:= 10.0
@export var projectile_speed:= 60.0
@export var projectile_range:= 2
@export var projectile_scale:= Vector3(1.0, 1.0, 1.0)
