extends AudioStreamPlayer

@onready var rhythm_notifier: RhythmNotifier = %RhythmNotifier
@onready var midi_player: MidiPlayer = %MidiPlayer
@onready var sampler_instrument: SamplerInstrument = %SamplerInstrument

var current_chord: Array[Array] = []

var beat_visualizer: CanvasLayer

var beat_count:= 0


var songs: Dictionary[String, AudioStream] = {
	"test" : preload("uid://bhcq425mgvjwe")
}


func _ready() -> void:
	rhythm_notifier.beat.connect(on_beat)
	midi_player.note.connect(on_midi_note_played)
	midi_player.link_audio_stream_player([self])
	midi_player.play()


func on_midi_note_played(event, track):
	midi_to_name(event.note)


func midi_to_name(midi_number):
	if current_chord.size() >= 4:
		current_chord.clear()
	
	# A list of note names for one octave
	var note_names = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
	# The number of notes in one octave
	var notes_per_octave = 12
	# The offset of the octave number from the midi number
	var octave_offset = 0
	# Calculate the note name and the octave number using modulo and division
	var note_name = note_names[midi_number % notes_per_octave]
	var octave_number = midi_number / notes_per_octave + octave_offset
	# Return the note name and the octave number as a string
	current_chord.append([note_name, octave_number - 4])


func play_midi():
	var sample:= sampler_instrument.samples[0]
	
	sampler_instrument.stop()
	
	print(current_chord)
	
	for note in current_chord:
		sample.tone = note[0]
		sample.octave = note[1]
		
		sampler_instrument.play_note(note[0], note[1])


func check_accuracy():
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
		Vars.last_activated_circle = circle
		circle.deactivate_zones()
		circle.recolor(level)
	else:
		Bus.beat_failure.emit()
	
	beat_visualizer.generate_text(accuracy)
	return accuracy


func on_beat(_interval: int):
	beat_count += 1
	Bus.beat.emit(beat_count)
