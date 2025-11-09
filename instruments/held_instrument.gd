extends CanvasLayer
class_name HeldInstrument
## Todo: make carillon do a shockwave instead of a projectile
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@export var sample: NoteSample = preload("res://assets/samples/lute_sample.tres")

var player: Player


func _ready() -> void:
	if player == null:
		printerr(self, ": Player not found")
		queue_free()
	
	Bus.player_cast.connect(on_player_cast)
	set_sample()


func set_sample():
	if sample == null:
		printerr(self, ": sample not found")
		return
	
	Bgm.sampler_instrument.samples[0] = sample


func animate_played(elements: Array[int] = []):
	animation_player.stop()
	if elements == []:
		animation_player.play("used_empty")
	
	if elements.size() > 0 and elements.size() < 3:
		animation_player.play("used_weak")
	
	if elements.size() >= 3:
		animation_player.play("used_strong")
	
	if not animation_player.current_animation == "idle":
		await animation_player.animation_finished
		animation_player.play("idle")


func on_player_cast(elements: Array[int], success: String = "missed"):
	animate_played(elements)
