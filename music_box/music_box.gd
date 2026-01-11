extends Node3D
class_name MusicBox
## Todo: Give important chests (unique loot) a different look and/or feel
## Todo: Fix sometimes not properly interactable (offset from center when rembembered)
@onready var sampler_instrument: SamplerInstrument3D = %SamplerInstrument
@onready var timer: Timer = %Timer
@onready var to_move: Node3D = %ToMove
@onready var crank_anim: AnimationPlayer = %CrankAnim
@onready var box: Node3D = %Box
@onready var small_box: Node3D = %SmallBox
@onready var omni_light_3d: OmniLight3D = %OmniLight3D
@onready var area_3d: Area3D = %Area3D
@onready var object_target: Marker3D = %ObjectTarget
@onready var object_origin: Marker3D = %ObjectOrigin
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var crank_sfx: AudioStreamPlayer3D = %CrankSFX
@onready var open_sfx: AudioStreamPlayer3D = %OpenSFX

@export var contents: Array[PackedScene] = []

@export var save_id: String = ""

var object_instances: Array[Node3D] = []

var box_id:= 0

var activated:= false
var opened:= false
var hovered:= false
var og_pos_of_to_move:= Vector3.ZERO


func _ready() -> void:
	og_pos_of_to_move = to_move.global_position
	
	init_contents()
	
	if contents == []:
		return
	
	area_3d.area_entered.connect(on_area_3d_area_entered)
	area_3d.area_exited.connect(on_area_3d_area_exited)


func init_contents():
	for i in range(contents.size()):
		var scene: PackedScene = contents[i]
		var object_inst: Node3D = scene.instantiate()
		var inst_save_id:= save_id + "_" + str(i)
		
		if SaveManager.check_node_collected(object_inst, inst_save_id) == true:
			if object_inst is SynapsePickup:
				Vars.synapses += 1
				Vars.total_synapses += 1
		
			if object_inst is NeuronPickup:
				Vars.neurons += 1
				Vars.total_neurons += 1
			
			object_inst.queue_free()
			continue
		
		set_inst_save_id(object_inst, inst_save_id)
		object_inst.process_mode = Node.PROCESS_MODE_DISABLED
		get_parent().add_child(object_inst)
		object_inst.global_position = Vector3(-100.0, -100.0, -100.0)
		object_instances.append(object_inst)


func set_inst_save_id(inst, inst_save_id):
	if not "save_id" in inst:
		return
	
	inst.save_id = inst_save_id


func _physics_process(delta: float) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		return
	
	if player.los.get_collider() == area_3d and global_position.distance_to(player.global_position) < Vars.interact_range:
		looked_at_by_player(true)
	else:
		looked_at_by_player(false)


func empty_contents():
	var object_list: Array[Node3D] = []
	
	for object: Node3D in object_instances:
		if not is_instance_valid(object):
			continue
	
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
	var extra_object_target:= first_object_target + Vector3(random_offset, target_pos.y, random_offset)
	
	if object_list.size() <= 1:
		target_pos = first_object_target
	
	if object_list.size() > 1:
		target_pos = extra_object_target
	
	if object is RigidBody3D:
		object.freeze = true
		object.linear_velocity = Vector3.ZERO
		object.angular_velocity = Vector3.ZERO
	
	if object.is_in_group("dopamine_cluster"):
		for child in object.get_children():
			if not child is RigidBody3D:
				continue
			
			child.freeze = true
		
		target_pos = global_position
	
	if object is Dopamine:
		target_pos = global_position + object.rand_position_offset
	
	tween.parallel().tween_property(
		object,
		"global_position",
		target_pos,
		Bgm.beat_timer.beat_length * 2
	).set_trans(Tween.TRANS_CUBIC)
	
	tween.parallel().tween_property(
		object,
		"scale",
		Vector3(1.0, 1.0, 1.0),
		Bgm.beat_timer.beat_length * 2
	).set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	
	if object is RigidBody3D:
			object.freeze = false
	
	if object.is_in_group("dopamine_cluster"):
		for child in object.get_children():
			if not child is RigidBody3D:
				continue
			
			child.freeze = false


func looked_at_by_player(on: bool):
	var box_hover: AnimationPlayer = box.hover
	
	if activated == true:
		to_move.global_position.y = og_pos_of_to_move.y
		return
	
	if on == true:
		to_move.global_position.y = og_pos_of_to_move.y + 0.05
		
		if box_hover.is_playing() == false and hovered == false:
			box_hover.play("hover")
		
		hovered = true
	
	if on == false:
		to_move.global_position.y = og_pos_of_to_move.y
		
		if box_hover.is_playing() == false and hovered == true:
			box.hover.play("unhover")
		
		hovered = false


func activate():
	if activated == true:
		return
	
	activated = true
	crank_anim.speed_scale *= Bgm.rhythm_notifier.bpm / 120
	crank_anim.play("crank")
	play_music()
	await crank_anim.animation_finished
	open()


func open():
	if box.open.is_playing():
		return
	
	if animation_player.is_playing():
		return
	
	box.open.play("open")
	open_sfx.play()
	
	await box.open.animation_finished
	
	opened = true
	animation_player.play("raise")
	
	await animation_player.animation_finished
	
	sampler_instrument.stop()
	small_box.hover.play("hover")
	small_box.open.play("open")
	open_sfx.pitch_scale = 1.6
	open_sfx.play()
	omni_light_3d.light_energy = 2.0
	
	empty_contents()


func play_music():
	if activated == false:
		return
	
	var chord: Array = Bgm.get_notes()
	
	if chord == null:
		return
	
	for note in chord:
		timer.start(randf_range(0.035, 0.045) * chord.size() / (Bgm.rhythm_notifier.bpm / 120))
		
		if randf() <= 0.33:
			play_single_note(chord.pick_random())
		else:
			play_single_note(note)
		
		await timer.timeout


func play_single_note(note, octave_modifier: int = 0):
	var sample:= sampler_instrument.samples[0]
	
	sample.tone = note[0]
	sample.octave = note[1] + octave_modifier
	
	if sample.octave < 0:
		sample.octave = 0
	
	sampler_instrument.play_note(sample.tone, sample.octave)


func crank_turn():
	crank_sfx.play()
	play_music()


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
