extends AudioStreamPlayer

@export var muted:= false

@onready var rhythm_notifier: RhythmNotifier = %RhythmNotifier

var beat_visualizer: CanvasLayer

var two_beat_count:= 0
var four_beat_count:= 0


var songs: Dictionary[String, AudioStream] = {
	"test" : preload("uid://bhcq425mgvjwe")
}


func _ready() -> void:
	rhythm_notifier.beat.connect(on_beat)
	if muted == true:
		volume_db = -80.0


func check_accuracy(element: String = "none"):
	var beat_area: Area2D = beat_visualizer.beat_area
	var circle: TimingCircle
	var accuracy:= "missed"
	var level:= 0
	
	Bus.beat_press_attempted.emit()
	
	for area in beat_area.get_overlapping_areas():
		if not "difficulty" in area:
			return accuracy
		
		if area.difficulty == "easy":
			level = 1
			accuracy = "easy"
		
		if area.difficulty == "medium":
			level = 2
			accuracy = "medium"
		
		if area.difficulty == "perfect":
			level = 3
			accuracy = "perfect"
		
		if area.owner is TimingCircle:
			circle = area.owner
	
	if not accuracy == "missed":
		Bus.beat_success.emit(level)
		Bus.beat_success_to_circle.emit(level, circle, element)
		Bus.beat_success_to_spellcast.emit(level, element)
		
		#if not element == "none":
			#Vars.last_element = element
	
	beat_visualizer.generate_text(accuracy)
	return accuracy


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
