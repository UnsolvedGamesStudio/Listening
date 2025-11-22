extends Node3D

@onready var hitbox: Area3D = %Hitbox

var damage:= 50.0


func _ready() -> void:
	hitbox.body_entered.connect(on_hitbox_body_entered)


func on_hitbox_body_entered(body):
	if body.owner.has_signal("hit_by_player_damage"):
		body.owner.hit_by_player_damage.emit(self)
