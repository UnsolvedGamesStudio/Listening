extends PanelContainer

@onready var offset_slider_label: Label = %OffsetSliderLabel
@onready var offset_slider: HSlider = %OffsetSlider


func _ready() -> void:
	offset_slider.value_changed.connect(on_offset_slider_value_changed)
	offset_slider.drag_ended.connect(on_offset_slider_drag_ended)

func on_offset_slider_value_changed(value: float) -> void:
	offset_slider_label.text = str("Beat Offset: ", int(value), "px")

func on_offset_slider_drag_ended(value_changed: bool) -> void:
	Vars.beat_circle_offset = offset_slider.value
