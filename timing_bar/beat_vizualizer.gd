extends CanvasLayer

const TIMING_CIRCLE = preload("uid://d0tfafh16tflf")
const RANK_LABEL = preload("uid://6w4l5x6wfeyn")

@onready var timing_bar: TextureRect = %TimingBar
@onready var middle_indicator: Sprite2D = %MiddleIndicator
@onready var beat_area: Area2D = %BeatArea
@onready var middle_indicator_anim: AnimationPlayer = $MiddleIndicator/MiddleIndicatorAnim

@export_range(1, 10) var height_modifier:= 1.2

var middle_of_screen:= Vector2.ZERO
var circle_spawn_pos:= Vector2.ZERO


func _ready() -> void:
	init_positions()
	connect_signals()


func init_positions():
	update_middle_of_screen()
	
	var height:= get_viewport().get_visible_rect().size.y / height_modifier
	
	timing_bar.global_position.y = height
	middle_indicator.global_position.x = middle_of_screen.x
	
	var middle_of_bar:= timing_bar.global_position.y + (timing_bar.size.y / 2)
	
	middle_indicator.global_position.y = middle_of_bar
	
	circle_spawn_pos.y = middle_of_bar
	circle_spawn_pos.x = 0


func connect_signals():
	Bus.any_beat.connect(on_beat_played)


func generate_circle():
	var circle_inst: timing_circle = TIMING_CIRCLE.instantiate()
	
	circle_inst.global_position = circle_spawn_pos
	circle_inst.beat_area = beat_area
	
	Vars.active_circles.append(circle_inst)
	
	add_child(circle_inst)


func update_middle_of_screen():
	middle_of_screen = get_viewport().get_visible_rect().size / 2


func pop_out_middle_indicator():
	middle_indicator_anim.play("pop_out")


func check_accuracy():
	var accuracy:= "missed"
	
	for area in beat_area.get_overlapping_areas():
		if not "difficulty" in area:
			return accuracy
		
		if area.difficulty == "easy":
			accuracy = "easy"
		
		if area.difficulty == "medium":
			accuracy = "medium"
		
		if area.difficulty == "perfect":
			accuracy = "perfect"
		
	return accuracy


func generate_text(accuracy: String):
	var text_inst: Label = RANK_LABEL.instantiate()
	
	text_inst.text = str(accuracy.capitalize(), "!")
	get_parent().add_child(text_inst)


func on_beat_played():
	update_middle_of_screen()
	generate_circle()
	
	## Test system's accuracy
	#print(check_accuracy())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") or event.is_action_pressed("activate"):
		pop_out_middle_indicator()
		generate_text(check_accuracy())
