extends Node3D
class_name WallCrack
## Todo: Maybe add a secret room manager to the level
## Todo: Add break particles
## Todo: Decouple cracked wall and secret room doorway/make new tile for simple cracked wall
## Todo: Hide secret room when not in use
## Todo: Fix level editor rotation not rotating this properly
const SECRET_ROOM_DOORWAY = preload("uid://bovh35e65gy48")

@onready var area_3d: Area3D = %Area3D
@onready var decal: Decal = %Decal
@onready var direction: Marker3D = %Direction

@export var secret_room_packed_scene:= preload("uid://bg6epqgk85ku3")

static var secret_room_amount:= 0

var secret_room: Node3D
var wall: Node3D


func _ready() -> void:
	decal.global_position = Vector3(-Vars.cell_size / 2, decal.global_position.y , 0.0)
	area_3d.area_entered.connect(on_area_entered)
	area_3d.body_entered.connect(on_body_entered)
	
	call_deferred("generate_secret_room")


func generate_secret_room():
	var room_inst: Node3D = secret_room_packed_scene.instantiate()
	var room_pos:= Vector3(200.0 * secret_room_amount, -200.0, 200.0)
	
	Find.layout().add_child(room_inst)
	room_inst.global_position = room_pos
	room_inst.global_rotation_degrees = direction.global_rotation_degrees
	
	generate_doorway(room_inst)
	
	secret_room = room_inst
	secret_room_amount += 1


func generate_doorway(room: Node3D):
	var doorway_inst: Node3D = SECRET_ROOM_DOORWAY.instantiate()
	
	Find.layout().add_child(doorway_inst)
	doorway_inst.global_position = global_position
	doorway_inst.global_rotation_degrees = direction.global_rotation_degrees
	
	var teleport_position: Vector3 = room.secret_room_doorway.teleport_target.global_position
	var teleport_back_position: Vector3 = doorway_inst.teleport_target.global_position
	
	doorway_inst.teleport_position = teleport_position
	room.secret_room_doorway.teleport_position = teleport_back_position


func detect_wall(object: Node3D):
	if object is WallCrack:
		return
	
	if not object.is_in_group("wall"):
		return
	
	wall = object
	#remove_wall()


func remove_wall():
	if wall == null:
		printerr(self, ": Wall not found")
		return
	
	wall.queue_free()
	queue_free()


func on_body_entered(body: Node3D):
	detect_wall(body.owner)


func on_area_entered(area: Area3D):
	detect_wall(area.owner)
	
	if not "breaks_walls" in area.owner:
		return
	
	if area.owner.breaks_walls == false:
		return
	
	remove_wall()
