extends Node3D
class_name MusicBox
## Todo: clean up music box script
@onready var sampler_instrument: SamplerInstrument3D = %SamplerInstrument
@onready var timer: Timer = %Timer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var crank_anim: AnimationPlayer = %CrankAnim
@onready var box: Node3D = %Box
@onready var small_box: Node3D = %SmallBox
@onready var omni_light_3d: OmniLight3D = %OmniLight3D
@onready var area_3d: Area3D = %Area3D
@onready var object_target: Marker3D = %ObjectTarget
@onready var object_origin: Marker3D = %ObjectOrigin

@export var contents: Array[PackedScene] = []
var object_instances: Array[Node3D] = []

var box_id:= 0

var activated:= false
var opened:= false
var times_played:= 0
var times_to_open:= 2


func _ready() -> void:
	for object: PackedScene in contents:
		var object_inst: Node3D = object.instantiate()
		object_inst.process_mode = Node.PROCESS_MODE_DISABLED
		get_parent().add_child(object_inst)
		object_inst.global_position = Vector3(100.0, 100.0, 100.0)
		object_instances.append(object_inst)
	
	if contents == []:
		return
	
	contents[0].instantiate()
	Bus.beat.connect(on_beat)
	area_3d.area_entered.connect(on_area_3d_area_entered)
	area_3d.area_exited.connect(on_area_3d_area_exited)


func _physics_process(delta: float) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		return
	
	if player.los.get_collider() == area_3d and global_position.distance_to(player.global_position) < Vars.interact_range:
		looked_at_by_player(true)
	else:
		looked_at_by_player(false)
	
	if activated == true and animation_player.is_playing() == false\
	and crank_anim.is_playing() == false and opened == false:
		crank_anim.play("crank")


func play_single_note(note):
	var sample:= sampler_instrument.samples[0]
	
	sample.tone = note[0]
	
	sampler_instrument.play_note(note[0], sample.octave, sample.velocity)


func empty_contents():
	var object_list: Array[Node3D] = []
	for object: Node3D in object_instances:
		object.process_mode = Node.PROCESS_MODE_INHERIT
		object.global_position = object_origin.global_position
		object.scale = Vector3(0.01, 0.01, 0.01)
		object_list.append(object)
		tween_object(object, object_list)


func tween_object(object: Node3D, object_list: Array[Node3D]):
	var tween:= create_tween()
	var target_pos:= Vector3.ZERO
	var random_offset: float = [0.8, -0.8, 0.5, -0.5, 0.3, -0.3].pick_random()
	var first_object_target:= object_target.global_position
	var extra_object_target:= target_pos + Vector3(random_offset, target_pos.y, random_offset)
	
	if object_list.size() <= 1:
		target_pos = first_object_target
	
	if object_list.size() > 1:
		target_pos = extra_object_target
	
	if object.is_in_group("dopamine_cluster"):
		target_pos = global_position
	
	if object is Dopamine:
		target_pos = global_position + object.rand_position_offset
		target_pos.y += 1.0
	
	tween.parallel().tween_property(object, "global_position", target_pos, Bgm.rhythm_notifier.beat_length * 2)
	tween.parallel().tween_property(object, "scale", Vector3(1.0, 1.0, 1.0), Bgm.rhythm_notifier.beat_length * 2)


func looked_at_by_player(on: bool):
	if activated == true:
		scale = Vector3(1.0, 1.0, 1.0)
		return
	
	if on == true:
		scale = Vector3(1.1, 1.1, 1.1)
	if on == false:
		scale = Vector3(1.0, 1.0, 1.0)


func activate():
	activated = true


func on_beat(beat_count: int):
	if activated == false:
		return
	
	if opened == true:
		return
	
	if beat_count % 4 == 0:
		return
	
	var chord: Array[Array] = Bgm.current_chord
	
	chord.reverse()
	
	for note in chord:
		timer.start(Bgm.rhythm_notifier.beat_length / 2)
		play_single_note(note)
		await timer.timeout
	
	times_played += 1
	
	if times_played >= 0:
		if opened == true:
			return
		
		open()


func open():
	opened = true
	
	if box.open.is_playing() or animation_player.is_playing():
		return
	
	box.open.play("open")
	await box.open.animation_finished
	animation_player.play("raise")
	await animation_player.animation_finished
	sampler_instrument.stop()
	small_box.open.play("open")
	omni_light_3d.light_energy = 2.0
	empty_contents()


func on_area_3d_area_entered(area: Area3D):
	if not area.is_in_group("player_collision"):
		return
	
	if not area.owner is Player:
		return
	
	var player: Node3D = area.owner
	var raise_amount:= 0.4
	
	if opened == true:
		raise_amount = 0.6
	
	create_tween().tween_property(player.camera, "position:y", raise_amount, 0.1)


func on_area_3d_area_exited(area: Area3D):
	if not area.is_in_group("player_collision"):
		return
	
	if not area.owner is Player:
		return
	
	var player: Node3D = area.owner
	
	create_tween().tween_property(player.camera, "position:y", 0.0, 0.1)
