extends CanvasLayer
class_name HeldInstrument
## Todo: make carillon do a shockwave instead of a projectile
## Todo: Standardize idle animation system
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@export var sample: NoteSample = preload("res://assets/samples/lute_sample.tres")
@export_range(-80.0, 80.0) var volume_db:= 0.0

@export var look_offset_pixels := 60

var sprite: Node2D
var player: Player

var base_y := 0.0
var look_offset := 0.0


func _ready() -> void:
	if player == null:
		push_error(self, ": Player not found")
		queue_free()
	
	sprite = get_node_or_null("ToMove/Sprite2D")
	if sprite:
		base_y = sprite.position.y
	
	play_idle()
	Bus.player_cast.connect(on_player_cast)


func _process(delta: float) -> void:
	adapt_to_camera(delta)


func adapt_to_camera(delta: float) -> void:
	if not sprite:
		return
	
	var camera: Camera3D = player.camera
	var pitch:= camera.rotation.x
	
	var normalized:= -pitch / (PI / 2.0)  ## [-1, 1]
	
	var target:= -normalized * look_offset_pixels
	
	look_offset = target
	
	sprite.position.y = base_y + look_offset


func animate_played(elements: Array[int] = []) -> void:
	animation_player.stop()
	animation_player.speed_scale = 1.0
	
	if elements == []:
		animation_player.play("used_empty")
	
	if elements.size() > 0 and elements.size() < 3:
		animation_player.play("used_weak")
	
	if elements.size() >= 3:
		animation_player.play("used_strong")
	
	if not animation_player.current_animation == "idle":
		await animation_player.animation_finished
		play_idle()


func play_idle():
	animation_player.speed_scale = 0.3 * (Bgm.beat_timer.bpm / 100)
	animation_player.play("idle")


func on_player_cast(elements: Array[int], success: String = "missed") -> void:
	animate_played(elements)
