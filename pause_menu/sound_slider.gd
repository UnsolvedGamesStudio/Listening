extends VSlider

enum types {MUSIC, SFX}
@export var type: types = types.MUSIC

static var any_being_dragged:= false


func _ready() -> void:
	set_slider_from_bus()
	
	value_changed.connect(on_value_changed)
	mouse_entered.connect(on_mouse_entered)
	drag_started.connect(on_drag_started)
	drag_ended.connect(on_drag_ended)


func set_slider_from_bus() -> void:
	var bus_name:= "MusicVolume"
	
	if type == types.MUSIC:
		bus_name = "MusicVolume"
	
	if type == types.SFX:
		bus_name = "SFXVolume"
	
	var bus:= AudioServer.get_bus_index(bus_name)
	var db:= AudioServer.get_bus_volume_db(bus)
	
	var linear:= db_to_linear(db)
	var new_value:= linear / 2.0
	
	value = clampf(new_value, 0.0, 1.0)


func on_mouse_entered():
	if any_being_dragged == true:
		return
	
	GlobalSfx.ui_hover.play()


func on_drag_started():
	any_being_dragged = true
	GlobalSfx.ui_click.play()


func on_drag_ended(new_value: float):
	any_being_dragged = false


func change_volume(slider_value: float):
	var linear:= value * 2.0
	linear = clampf(linear, 0.0, 2.0)
	
	var volume:= linear_to_db(linear)
	var bus_index: int = 0
	
	if type == types.MUSIC:
		bus_index = AudioServer.get_bus_index("MusicVolume")
	
	if type == types.SFX:
		bus_index = AudioServer.get_bus_index("SFXVolume")
	
	AudioServer.set_bus_volume_db(bus_index, volume)


func on_value_changed(slider_value: float):
	GlobalSfx.ui_hover.play(0.02)
	change_volume(slider_value)
