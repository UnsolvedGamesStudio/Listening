extends CanvasLayer

const TIMING_CIRCLE = preload("uid://d0tfafh16tflf")

@onready var timing_bar: TextureRect = %TimingBar
@onready var middle_indicator: Sprite2D = %MiddleIndicator
@onready var beat_area: Area2D = %BeatArea
@onready var middle_indicator_anim: AnimationPlayer = $MiddleIndicator/MiddleIndicatorAnim

@export_range(1, 10) var height_modifier:= 1.2

var middle_of_screen:= 0.0
var left_start_pos:= Vector2.ZERO
var right_start_pos:= Vector2.ZERO



func _ready() -> void:
	init_positions()
	connect_signals()


func init_positions():
	update_middle_of_screen()
	
	var height:= get_viewport().get_visible_rect().size.y / height_modifier
	
	timing_bar.global_position.y = height
	middle_indicator.global_position.x = middle_of_screen
	
	var middle_of_bar:= timing_bar.global_position.y + (timing_bar.size.y / 2)
	
	middle_indicator.global_position.y = middle_of_bar
	
	left_start_pos.y = middle_of_bar
	left_start_pos.x = -32
	
	right_start_pos.y = middle_of_bar 
	right_start_pos.x = get_viewport().get_visible_rect().size.x + 32


func connect_signals():
	Bus.first_of_two_beats.connect(on_beat_played)


func generate_circle(starting_point:= "left"):
	var circle_inst: timing_circle = TIMING_CIRCLE.instantiate()
	
	if starting_point == "left":
		circle_inst.global_position = left_start_pos
		circle_inst.direction = 1.0
	
	if starting_point == "right":
		circle_inst.global_position = right_start_pos
		circle_inst.direction = -1.0
	
	circle_inst.kill_point = middle_of_screen
	Vars.active_circles.append(circle_inst)
	
	add_child(circle_inst)


func update_middle_of_screen():
	middle_of_screen = get_viewport().get_visible_rect().size.x / 2


func pop_out_middle_indicator():
	middle_indicator_anim.play("pop_out")


func on_beat_played():
	update_middle_of_screen()
	generate_circle("left")


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("left_click") or event.is_action_pressed("activate"):
		return
		
	pop_out_middle_indicator()
	
	for area in beat_area.get_overlapping_areas():
		if not "difficulty" in area:
			return
		
		print(area.difficulty)
