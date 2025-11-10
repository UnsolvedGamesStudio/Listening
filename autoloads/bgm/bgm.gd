extends AudioStreamPlayer
@onready var rhythm_notifier: RhythmNotifier = %RhythmNotifier
@onready var midi_player: MidiPlayer = %MidiPlayer
@onready var sampler_instrument: SamplerInstrument = %SamplerInstrument
@onready var kick: AudioStreamPlayer = %Kick
@onready var pause_menu_music: AudioStreamPlayer = %PauseMenuMusic
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var non_beat_bgm: AudioStreamPlayer = %NonBeatBGM

var combo_label: ComboManager

var current_chord: Array[Array] = []

var beat_visualizer: CanvasLayer

var beat_count:= 0
var last_timing:= 0.0
var circles_are_in:= false


var songs: Dictionary[String, AudioStream] = {
	"test" : preload("uid://bhcq425mgvjwe")
}


func _ready() -> void:
	rhythm_notifier.beat.connect(on_beat)
	midi_player.note.connect(on_midi_note_played)


func start_song():
	play()
	kick.play()
	midi_player.play()


func stop_song():
	stop()
	kick.stop()
	midi_player.stop()


func on_midi_note_played(event, track):
	midi_to_name(event.note)


func midi_to_name(midi_number):
	## Todo: change this to be timing based, or have an option to be, and an option for chord size
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


func play_sample(elements: Array[int] = []):
	if current_chord == []:
		play_note_no_music(elements)
		return
	
	var sample:= sampler_instrument.samples[0]
	
	sampler_instrument.stop()
	
	if elements == []:
		play_single_note(current_chord.pick_random(), 2)
	
	if elements.size() == 3:
		play_full_chord()
		return
	
	for element in elements:
		if element == 0:
			play_single_note(current_chord[-1], 1)
		
		if element == 1:
			play_single_note(current_chord[0], 1)
		
		if element == 2:
			play_single_note(current_chord[2], 1)
	
	## v Plays each note with octave based on when it is played v
	#var plays:= 0
	#for element in elements:
		#print(plays)
		#if element == 0:
			#play_single_note(current_chord[-1], 2)
			#if plays == 1:
				#play_single_note(current_chord[-1], 1)
			#if plays == 2:
				#play_single_note(current_chord[-1], 0)
#
		#if element == 1:
			#play_single_note(current_chord[0], 0)
			#if plays == 1:
				#play_single_note(current_chord[-1], -1)
			#if plays == 2:
				#play_single_note(current_chord[-1], -2)
		#
		#if element == 2:
			#play_single_note(current_chord[2], 1)
			#if plays == 1:
				#play_single_note(current_chord[-1], 0)
			#if plays == 2:
				#play_single_note(current_chord[-1], -1)
		#
		#plays +=1


func play_note_no_music(elements):
		var note_names = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
		
		if elements == []:
			play_single_note(note_names.pick_random(), 2)
		
		else:
			for element in elements:
				if element == 0:
					play_single_note("C", 1)
				if element == 1:
					play_single_note("E", 1)
				if element == 2:
					play_single_note("G", 1)


func play_single_note(note, octave: int = 0):
	var octave_modifier:= -1
	
	var sample:= sampler_instrument.samples[0]
	
	sample.tone = note[0]
	sample.octave = -1
	
	sampler_instrument.play_note(note[0], octave + octave_modifier)


func play_full_chord(octave_modifier: int = 1):
	if current_chord == []:
		return
	
	var sample:= sampler_instrument.samples[0]
	
	for note in current_chord:
		sample.tone = note[0]
		sample.octave = note[1]
		
		sampler_instrument.play_note(note[0], note[1] - octave_modifier)


func check_accuracy(punished_for_bad_timing:= false):
	if beat_visualizer == null:
		return "perfect"
	
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
	
	if circles_are_in == false:
		accuracy = check_silent_timing()
	
	if not accuracy == "missed":
		Bus.beat_success.emit(level)
	
	if not accuracy == "missed" and circles_are_in == true:
		Vars.last_activated_circle = circle
		circle.deactivate_zones()
		circle.recolor(level)
	
	if accuracy == "missed" and punished_for_bad_timing == true:
		Bus.beat_failure.emit()
	
	beat_visualizer.generate_text(accuracy)
	return accuracy


func check_silent_timing():
	var window: float = rhythm_notifier.beat_length
	var success:= "missed"
	
	var easy_timing = Bgm.rhythm_notifier.current_position > (last_timing - (window / 2.9) ) and\
	Bgm.rhythm_notifier.current_position < (last_timing + (window / 2.9) )
	var medium_timing = Bgm.rhythm_notifier.current_position > (last_timing - (window / 3.8) ) and\
	Bgm.rhythm_notifier.current_position < (last_timing + (window / 3.8) )
	var perfect_timing = Bgm.rhythm_notifier.current_position > (last_timing - (window / 4.5) ) and\
	Bgm.rhythm_notifier.current_position < (last_timing + (window / 4.5) )
	
	if easy_timing:
		success = "easy"
	if medium_timing:
		success = "medium"
	if perfect_timing:
		success = "perfect"
	
	return success


func play_kick():
	kick.play()


func check_real_timing():
	last_timing = rhythm_notifier.current_position


func on_beat(_interval: int):
	if Vars.paused == false:
		beat_count += 1
	
	check_real_timing()
	play_kick()
	Bus.beat.emit(beat_count)
