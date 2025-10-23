extends Resource
class_name EnemyResource

@export var name:= "Name"
@export var description:= "Description"

@export var preferred_range: ranges
enum ranges{MELEE, RANGED, CONTACT}

@export var body_damage:= 10.0
@export var impassable:= false

@export var vision_limit:= 10.0

@export var behaviors: Array[NodePath] = [
	"res://enemies/behaviors/get_hurt_eb.tscn",
	"res://enemies/behaviors/movement_eb.tscn",
	"res://enemies/behaviors/ranged_attack_eb.tscn",
	"res://enemies/behaviors/melee_attack_eb.tscn",
]
