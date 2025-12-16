extends PanelContainer

@onready var offset_slider_label: Label = %OffsetSliderLabel
@onready var offset_slider: HSlider = %OffsetSlider

static var any_being_dragged:= false


func _ready() -> void:
	offset_slider_label.text = str("Beat Offset: ", Vars.beat_circle_offset, "ms")
	offset_slider.value = Vars.beat_circle_offset
	
	offset_slider.mouse_entered.connect(on_offset_slider_mouse_entered)
	offset_slider.drag_started.connect(on_offset_slider_drag_started)
	offset_slider.value_changed.connect(on_offset_slider_value_changed)
	offset_slider.drag_started.connect(on_offset_slider_started)
	offset_slider.drag_ended.connect(on_offset_slider_drag_ended)


func on_offset_slider_mouse_entered():
	GlobalSfx.ui_hover.play()


func on_offset_slider_drag_started():
	GlobalSfx.ui_click.play()


func on_offset_slider_started():
	any_being_dragged = true
	GlobalSfx.ui_click.play()


func on_offset_slider_value_changed(value: float) -> void:
	GlobalSfx.ui_hover.play(0.02)
	Vars.beat_circle_offset = offset_slider.value
	offset_slider_label.text = str("Beat Offset: ", Vars.beat_circle_offset, "ms")


func on_offset_slider_drag_ended(value_changed: bool) -> void:
	Vars.beat_circle_offset = offset_slider.value
