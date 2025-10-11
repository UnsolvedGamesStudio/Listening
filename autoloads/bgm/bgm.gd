extends AudioStreamPlayer

@onready var rhythm_notifier: RhythmNotifier = %RhythmNotifier

var two_beat_count:= 0
var four_beat_count:= 0

var songs: Dictionary[String, AudioStream] = {
	"test" : preload("uid://bhcq425mgvjwe")
}


func _ready() -> void:
	rhythm_notifier.beat.connect(on_beat)


func on_beat(_interval: int):
	two_beat_count += 1
	four_beat_count += 1
	
	Bus.any_beat.emit()
	
	if two_beat_count == 1:
		Bus.first_of_two_beats.emit()
	
	if two_beat_count == 2:
		Bus.second_of_two_beats.emit()
		two_beat_count = 0
	
	if four_beat_count == 1:
		Bus.first_of_four_beats.emit()
	
	if four_beat_count == 3:
		Bus.third_of_four_beats.emit()
	
	if four_beat_count == 4:
		Bus.fourth_of_four_beats.emit()
		four_beat_count = 0
