extends Resource
class_name EnemyData

@export_group("Info")
@export var id:= "id"
@export var name:= "Name"
@export var description:= "Description"

@export_group("AI")
@export var preferred_range: ranges
enum ranges{MELEE, RANGED, CONTACT}
@export var aggro_distance:= 4.0
@export var vision_limit:= 10.0
@export var vertical_vision_range:= 2.0
@export var can_move_diagonally:= false

@export_group("Stats")
@export var max_hp:= 100.0
@export var movement_speed:= 4
@export var impassable:= false
@export var body_damage:= 10.0
@export var counts_towards_goal:= true

@export_group("Timings")
@export var moves_every_x_beat:= 4
@export var melees_every_x_beat:= 4
@export var shoots_every_x_beat:= 6

@export_group("Melee")
@export var melee_range:= 1
@export var melee_damage:= 20.0

@export_group("Projectile")
@export var projectile_enabled:= true
@export var projectile_texture:= preload("uid://dgygswxu7j8ds")
@export var projectile_damage:= 10.0
@export var projectile_speed:= 60.0
@export var projectile_range:= 2
@export var projectile_scale:= Vector3(1.0, 1.0, 1.0)
@export var projectile_height_offset:= 0.0

@export_group("Vulnerablities")
@export var joy_damage_mult:= 1.0
@export var sad_damage_mult:= 1.0
@export var anger_damage_mult:= 1.0

@export_group("drops")
@export_file_path() var drop
@export_range(0.0, 1.0) var drop_chance:= 1.0
