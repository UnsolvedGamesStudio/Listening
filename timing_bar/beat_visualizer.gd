extends CanvasLayer
class_name BeatVisualizer
## Todo: If spawn rate is lowered: make it only work every x beat
const TIMING_CIRCLE = preload("uid://d0tfafh16tflf")
const RANK_LABEL = preload("uid://6w4l5x6wfeyn")

@onready var timing_bar: TextureRect = %TimingBar
@onready var beat_activator: Sprite2D = %BeatActivator
@onready var beat_area: Area2D = %BeatArea
@onready var beat_activator_anim: AnimationPlayer = %BeatActivatorAnim
@onready var succes_label_container: Panel = %SuccesLabelContainer

@export_range(1, 10) var height:= 0.0

var last_spawned_beat := -1


func _ready() -> void:
	Bgm.beat_visualizer = self
	height = (get_middle_of_screen().y * 2.0) / 1.16
	
	init_bar_position()
	connect_signals()


func init_bar_position():
	var middle_of_bar:= timing_bar.texture.get_size() / 2
	
	timing_bar.global_position.y = height
	beat_activator.global_position = Vector2(get_middle_of_screen().x, height + middle_of_bar.y)


func connect_signals():
	Bgm.circle_beat_timer.circle_beat.connect(on_beat)
	Bus.beat_press_attempted.connect(on_beat_press_attempted)


func set_circle_values_for_appropriate_beat(circle_inst: TimingCircle, start_offset: float = 0.0) -> void:
	var behind_left := -circle_inst.texture.get_size().x
	var right_edge := get_viewport().get_visible_rect().size.x
	var behind_right := right_edge + circle_inst.texture.get_size().x

	var start_pos := Vector2(behind_left + start_offset, beat_activator.position.y)
	var middle_pos := beat_activator.position
	var end_pos := Vector2(behind_right, beat_activator.position.y)

	circle_inst.start_pos = start_pos
	circle_inst.middle_pos = middle_pos
	circle_inst.end_pos = end_pos

	circle_inst.position = start_pos


func generate_circle_for_next_beat(start_offset: float = 0.0):
	var circle_inst: TimingCircle = TIMING_CIRCLE.instantiate()
	
	# compute the next beat target time (one beat ahead)
	var now = Bgm.circle_beat_timer.audio_pos
	var next_beat_time = now + Bgm.circle_beat_timer.beat_length
	
	# set values (includes calling setup_for_beat on the circle)
	add_child(circle_inst)
	set_circle_values_for_appropriate_beat(circle_inst, start_offset)
	Bus.circle_spawned.emit()
	
	Vars.active_circles.append(circle_inst)


func get_middle_of_screen():
	return get_viewport().get_visible_rect().size / 2


func pop_out_beat_activator():
	beat_activator_anim.play("pop_out")


func generate_text(accuracy: String):
	var text_inst:= RANK_LABEL.instantiate()
	var text:= ""
	
	if accuracy == "easy":
		text = "OK..."
	
	if accuracy == "medium":
		text = "Nice."
	
	if accuracy == "perfect":
		text = "Perfect!"
	
	text_inst.text = str(text)
	succes_label_container.add_child(text_inst)


func on_beat_press_attempted():
	pop_out_beat_activator()

#var _last_beat_time := -1.0


func on_beat(_beat_count: int) -> void:
	var now : float = Bgm.circle_beat_timer.audio_pos
	var beat_len : float = Bgm.circle_beat_timer.beat_length
	var beat_idx := int(floor(now / beat_len))

	# How many beats ahead a circle must target to have time to travel to middle
	var beats_ahead := int(ceil(TIMING_CIRCLE.instantiate().travel_to_middle_duration / beat_len))
	# (Optional optimization: cache this value instead of instantiating. See note below.)

	var target_idx := beat_idx + beats_ahead

	while last_spawned_beat < target_idx:
		last_spawned_beat += 1
		spawn_circle_for_beat(last_spawned_beat)


func spawn_circle_for_beat(beat_idx: int) -> void:
	var beat_len: float = Bgm.circle_beat_timer.beat_length
	var target_beat_time := float(beat_idx) * beat_len
	
	var circle: TimingCircle = TIMING_CIRCLE.instantiate()
	
	add_child(circle)
	set_circle_values_for_appropriate_beat(circle)
	circle.setup_for_beat(target_beat_time)
	
	Bus.circle_spawned.emit()
	
	Vars.active_circles.append(circle)


func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_L):
		OS.delay_msec(60)
