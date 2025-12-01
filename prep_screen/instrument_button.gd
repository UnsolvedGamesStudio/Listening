@tool
extends PanelContainer
class_name InstrumentButton
## Todo: Play a sample of the instrument when selected
## Todo: Make tooltip show up to explain the instrument
## Todo: MAYBE make this into a physical room instead with 3d ui?
@onready var instrument_icon: TextureRect = %InstrumentIcon
#@onready var selection_outline: PanelContainer = %SelectionOutline

@export var icon:= preload("res://instruments/textures/lute.png")
@export var instrument:= Vars.instrument_types.LUTE


func _ready() -> void:
	instrument_icon.texture = icon
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if Vars.current_instrument == instrument:
		scale = Vector2(1.1, 1.1)
		modulate.a = 1.0
		#selection_outline.show()
		return
	
	#selection_outline.hide()
	self_modulate.a = 0.5
	scale = Vector2.ONE


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("cast"):
		on_clicked()


func on_clicked():
	GlobalSfx.ui_click.play()
	Vars.current_instrument = instrument


func on_mouse_entered():
	if Vars.current_instrument == instrument:
		return
	
	GlobalSfx.ui_hover.play()
	modulate.a = 0.8


func on_mouse_exited():
	if Vars.current_instrument == instrument:
		return
	
	modulate.a = 1.0
