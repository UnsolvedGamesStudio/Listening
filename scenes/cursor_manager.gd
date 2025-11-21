extends Node

@onready var cursor_sparkles: GPUParticles2D = %CursorSparkles

const CURSOR_NEUTRAL = preload("uid://cg4tlnn6sfc5j")
const CURSOR_HOVER = preload("uid://hs8dti0jbbba")
const CURSOR_CLICK = preload("uid://d3po7d2es7mo2")


func _ready() -> void:
	Input.set_custom_mouse_cursor(CURSOR_CLICK, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(CURSOR_CLICK, Input.CURSOR_POINTING_HAND)


func _physics_process(delta: float) -> void:
	if not Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		if cursor_sparkles.emitting == true:
			cursor_sparkles.emitting = false
		return
	
	if not Input.is_action_pressed("cast"):
		if cursor_sparkles.emitting == true:
			cursor_sparkles.emitting = false
		return
	
	if cursor_sparkles.emitting == false:
		cursor_sparkles.emitting = true
	
	cursor_sparkles.position = get_viewport().get_mouse_position()


func _input(event: InputEvent) -> void:
	if not Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
	
	if event.is_action_pressed("cast"):
		Input.set_custom_mouse_cursor(CURSOR_CLICK, Input.CURSOR_ARROW)
		Input.set_custom_mouse_cursor(CURSOR_CLICK, Input.CURSOR_POINTING_HAND)
	else:
		Input.set_custom_mouse_cursor(CURSOR_NEUTRAL, Input.CURSOR_ARROW)
		Input.set_custom_mouse_cursor(CURSOR_HOVER, Input.CURSOR_POINTING_HAND)
