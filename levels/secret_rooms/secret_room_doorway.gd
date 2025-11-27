extends Node3D

@onready var teleporter: Area3D = %Teleporter
@onready var teleport_target: Marker3D = %TeleportTarget

var teleport_position: Vector3


func _ready() -> void:
	teleporter.area_entered.connect(on_teleporter_area_entered)


func teleport_player(player: Player):
	player.can_act = false
	Filters.fade_black.play("fade_out")
	await Filters.fade_black.animation_finished
	player.global_position = teleport_position
	Filters.fade_black.play("fade_in")
	await Filters.fade_black.animation_finished
	player.can_act = true


func on_teleporter_area_entered(area: Area3D):
	if not area.is_in_group("player_collision"):
		return
	
	var player: Player = area.owner
	
	if teleport_position == null:
		printerr(self, ": Teleport position not set")
		return
	
	teleport_player(player)
