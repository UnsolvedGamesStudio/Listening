extends CanvasLayer
class_name BeatVisualizer
## Todo: Increase the size of bar and circles
const TIMING_CIRCLE = preload("uid://d0tfafh16tflf")
const RANK_LABEL = preload("uid://6w4l5x6wfeyn")
const BEAT_TIMER = preload("uid://dwk7ovxfs2mxp")

@onready var timing_bar: TextureRect = %TimingBar
@onready var beat_activator: Sprite2D = %BeatActivator
@onready var beat_area: Area2D = %BeatArea
@onready var beat_activator_anim: AnimationPlayer = %BeatActivatorAnim
@onready var succes_label_container: Panel = %SuccesLabelContainer

@export_range(1, 10) var height:= 0.0


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
	Bus.beat.connect(on_beat)
	Bus.beat_press_attempted.connect(on_beat_press_attempted)


func set_circle_values_for_appropriate_beat(circle_inst: TimingCircle, start_offset: float = 0.0) -> void:
	var now : float = Bgm.rhythm_notifier.current_position
	var sec_per_beat : float = Bgm.rhythm_notifier.beat_length

	# how many beats ahead we must aim so the circle *starts* at/after now
	var beats_ahead := int(ceil(circle_inst.travel_to_middle_duration / sec_per_beat))
	if beats_ahead < 1:
		beats_ahead = 1

	var target_beat_time : float = now + beats_ahead * sec_per_beat

	# compute local positions relative to this CanvasLayer (BeatVisualizer)
	var behind_left := -circle_inst.texture.get_size().x
	var right_edge := get_viewport().get_visible_rect().size.x
	var behind_right := right_edge + circle_inst.texture.get_size().x

	# use local 'position' of beat_activator (BeatVisualizer node coordinates)
	var start_pos := Vector2(behind_left + start_offset, beat_activator.position.y)
	var middle_pos := beat_activator.position
	var end_pos := Vector2(behind_right, beat_activator.position.y)

	circle_inst.start_pos = start_pos
	circle_inst.middle_pos = middle_pos
	circle_inst.end_pos = end_pos
	circle_inst.beat_area = beat_area

	# give it the target beat time so it calculates spawn_time and initial position
	circle_inst.setup_for_beat(target_beat_time)


func generate_circle_for_next_beat(start_offset: float = 0.0):
	var circle_inst: TimingCircle = TIMING_CIRCLE.instantiate()
	
	# compute the next beat target time (one beat ahead)
	var now = Bgm.rhythm_notifier.current_position
	var next_beat_time = now + Bgm.rhythm_notifier.beat_length
	
	# set values (includes calling setup_for_beat on the circle)
	set_circle_values_for_appropriate_beat(circle_inst, start_offset)
	
	Vars.active_circles.append(circle_inst)
	add_child(circle_inst)


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


func on_beat(_beat_count: int) -> void:
	# instead of spawning for the *current* beat, spawn a circle that will land on the next beat.
	generate_circle_for_next_beat()
	#var timer_inst: Timer = BEAT_TIMER.instantiate()
	#
	#timer_inst.wait_time = Bgm.rhythm_notifier.beat_length
	#add_child(timer_inst)


func on_beat_timer_timeout():
	pass
	#update_middle_of_screen()
	#generate_circle()
	
	## Test system's accuracy
	#Bgm.check_accuracy()
