extends Resource
class_name ProjectileData

@export_group("Stats")
@export var extra_amount:= 0
@export var delay:= 0.2
@export var damage_mult:= 1.0
@export var speed_mult:= 1.0
@export var max_distance_mult:= 1.0
@export var max_lifetime_mult: float = 1.0

@export_group("Behavior")
@export var destroy_on_entity:= true
@export var destroy_on_terrain:= true
@export var momentum_decay_rate:= 0.0
@export var pierce_entities:= false
@export var repeat_hit_cooldown: float = 0.1

@export_file_path() var projectile_effect_path:= ""
@export_subgroup("Bounce")
@export var bouncy:= false
@export var speed_mult_on_bounce:= 1.0
@export var spawn_randomness:= 0.0

@export_subgroup("Cannon Ball")
@export var cannon_ball:= false
@export_range(1.01, 1.2) var cannon_ball_friction:= 1.05
@export var cannon_ball_bounce:= 0.3

@export_group("Appearance")
@export var color:= Color.WHITE
@export var produce_destroyed_vfx:= true
@export_subgroup("Sprite")
@export var texture: Texture
@export var h_frames:= 1
@export var animate:= false
@export_subgroup("SFX")
@export_file_path() var spawn_sfx:= "res://assets/sfx/projectile_spawn_sfx.ogg"
@export_file_path() var passive_sfx:= ""
@export_file_path() var bounce_sfx:= "res://assets/sfx/projectile_impact_sfx.ogg"
@export_file_path() var expire_sfx:= ""
@export_file_path() var destroy_sfx:= "res://assets/sfx/projectile_impact_sfx.ogg"
@export_range(0.0, 1.5) var randomize_pitch_range:= 0.05
