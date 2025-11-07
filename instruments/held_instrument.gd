extends CanvasLayer
class_name HeldInstrument

@onready var animation_player: AnimationPlayer = %AnimationPlayer
var player: Player


func _ready() -> void:
	player = get_parent()
	
	if player == null:
		queue_free()
	
	Bus.player_cast.connect(on_player_cast)


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
