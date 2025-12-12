extends AudioStreamPlayer
## Todo: Make played octave relative to a default rather than copying the midi
@onready var rhythm_notifier: RhythmNotifier = %RhythmNotifier
@onready var midi_player: MidiPlayer = %MidiPlayer
@onready var sampler_instrument: SamplerInstrument = %SamplerInstrument
@onready var correct_timing_sound: SamplerInstrument = %CorrectTimingSound
@onready var kick: AudioStreamPlayer = %Kick
@onready var pause_menu_music: AudioStreamPlayer = %PauseMenuMusic
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var non_beat_bgm: AudioStreamPlayer = %NonBeatBGM
@onready var chord_timing: Timer = %ChordTiming

var combo_label: ComboManager
var beat_visualizer: CanvasLayer

var current_song_data: SongData

var current_midi_notes:= []
var beat_count:= 0
var last_timing:= 0.0
var circles_are_in:= false

var event_history: Dictionary[float, int] = {}


func _ready() -> void:
	var main = get_tree().get_first_node_in_group("main_scene")
	
	current_song_data = main.default_song
	
	rhythm_notifier.beat.connect(on_beat)
	midi_player.midi_event.connect(on_midi_event)
	
	if get_tree().get_first_node_in_group("main_scene").always_start_bgm == true:
		start_song()


func on_midi_event( channel, event ):
	match event.type:
		SMF.MIDIEventType.note_on:
			add_note_to_array(event.note)
		
		SMF.MIDIEventType.note_off:
			remove_note_from_array(event.note)


func start_song():
	if playing == true:
		return
	
	init_song_data()
	
	play()
	kick.play()
	
	if midi_player.file == null:
		push_error(self, ": Midi file not found")
		return
	
	midi_player.play()
	midi_player.set_tempo(rhythm_notifier.bpm)


func stop_song():
	stop()
	kick.stop()
	midi_player.stop()


func init_song_data():
	stream = load(current_song_data.file_path)
	rhythm_notifier.bpm = current_song_data.bpm
	midi_player.file = current_song_data.chords_midi_path
	volume_db = current_song_data.volume


func add_note_to_array(note):
	if note in current_midi_notes:
		return
	
	current_midi_notes.append(note)


func remove_note_from_array(note):
	current_midi_notes.erase(note)


func get_notes() -> Array:
	var returned_array:= []
	var sorted_notes:= current_midi_notes
	sorted_notes.sort()
	
	for note in sorted_notes:
		returned_array.append( translate_midi(note) )
	
	return returned_array


## make octave accurate
func translate_midi(midi_number):
	# A list of note names for one octave
	var note_names = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
	
	# The number of notes in one octave
	var notes_per_octave = 12
	
	# The offset of the octave number from the midi number
	var octave_offset = 0
	
	# Calculate the note name and the octave number using modulo and division
	var note_name = note_names[midi_number % notes_per_octave]
	var octave_number = midi_number / notes_per_octave + octave_offset
	
	# Return the note name and the octave number as an array
	return [note_name, octave_number]

#func read_chord(midi_number):
	#if current_chord.size() >= 4:
		#current_chord.clear()
	#
	## A list of note names for one octave
	#var note_names = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
	## The number of notes in one octave
	#var notes_per_octave = 12
	## The offset of the octave number from the midi number
	#var octave_offset = 0
	## Calculate the note name and the octave number using modulo and division
	#var note_name = note_names[midi_number % notes_per_octave]
	#var octave_number = midi_number / notes_per_octave + octave_offset
	## Return the note name and the octave number as a string
	#current_chord.append([note_name, octave_number - 4])


func play_sample(elements: Array[int] = []):
	if get_notes() == []:
		play_note_no_music(elements)
		return
	
	var sample:= sampler_instrument.samples[0]
	
	sampler_instrument.stop()
	
	if elements == []:
		play_single_note(get_notes().pick_random(), 2)
	
	if elements.size() == 3:
		play_full_chord()
		return
	
	for element in elements:
		if element == 0:
			play_highest_note()
		
		if element == 1:
			play_lowest_note()
		
		if element == 2:
			play_middle_note()


func play_lowest_note():
	var note_to_play: Array = get_notes()[0]
	play_single_note(note_to_play)


func play_highest_note():
	var note_to_play: Array = get_notes()[-1]
	play_single_note(note_to_play)


func play_middle_note():
	var current_notes := get_notes()
	var count := current_notes.size()
	if count == 0:
		return
	
	var idx := (count - 1) / 2.0
	if count % 2 == 0:
		# even → two middle elements → random tie-breaker
		idx += randi() % 2
	
	var note_to_play = current_notes[idx]
	play_single_note(note_to_play)


func play_note_no_music(elements):
	#var note_names:= ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
	#var c_maj:= ["C", "D", "E", "F", "G", "A", "B"]
	var b_melodic_min:= ["B", "C#", "D", "E", "F#", "G#", "A#"]
	var sample:= sampler_instrument.samples[0]
	
	if elements == []:
		sampler_instrument.play_note(b_melodic_min.pick_random(), sample.octave + 1)
	
	if elements.size() == 3:
		sampler_instrument.play_note("B", sample.octave)
		sampler_instrument.play_note("E", sample.octave)
		sampler_instrument.play_note("G#", sample.octave)
		return
	
	for element in elements:
		if element == 0:
			sampler_instrument.play_note("B", sample.octave)
		if element == 1:
			sampler_instrument.play_note("E", sample.octave)
		if element == 2:
			sampler_instrument.play_note("G#", sample.octave)


func play_single_note(note, octave_modifier: int = 0):
	var sample:= sampler_instrument.samples[0]
	var exception_octave:= 0 ## Temporary
	
	if Vars.current_instrument == Vars.instrument_types.CARILLON:
		exception_octave = 5
	
	sample.tone = note[0]
	sample.octave = note[1] - exception_octave + octave_modifier - 1
	
	if sample.octave < 0:
		sample.octave = 0
	
	sampler_instrument.play_note(sample.tone, sample.octave)


func play_full_chord(octave_modifier: int = 0):
	if get_notes() == []:
		return
	
	var sample:= sampler_instrument.samples[0]
	
	for note in get_notes():
		play_single_note(note, octave_modifier)


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
		
		play_correct_chime(true)
		
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
		play_correct_chime(false)
		Bus.beat_failure.emit()
	
	beat_visualizer.generate_text(accuracy)
	return accuracy


func check_silent_timing():
	var window: float = rhythm_notifier.beat_length
	var accuracy:= "missed"
	
	var easy_timing = Bgm.rhythm_notifier.current_position > (last_timing - (window / 2.9) ) and\
	Bgm.rhythm_notifier.current_position < (last_timing + (window / 2.9) )
	var medium_timing = Bgm.rhythm_notifier.current_position > (last_timing - (window / 3.8) ) and\
	Bgm.rhythm_notifier.current_position < (last_timing + (window / 3.8) )
	var perfect_timing = Bgm.rhythm_notifier.current_position > (last_timing - (window / 4.5) ) and\
	Bgm.rhythm_notifier.current_position < (last_timing + (window / 4.5) )
	
	if easy_timing:
		accuracy = "easy"
	if medium_timing:
		accuracy = "medium"
	if perfect_timing:
		accuracy = "perfect"
	
	return accuracy


func play_correct_chime(hit: bool):
	if correct_timing_sound.playing == true:
		return
	
	var sample:= sampler_instrument.samples[0]
	var note: Array = []
	var current_notes:= get_notes()
	sample.octave = 4
	
	if not current_notes == []:
		note = current_notes[-1]
	
	if not note == []:
		sample.tone = note[0]
	
	if sample.octave < 0:
		sample.octave = 0
	
	if hit == false and not current_midi_notes == []:
		sample.tone = translate_midi(current_midi_notes[-1] - 1)[0]
	
	correct_timing_sound.play_note(sample.tone, sample.octave)


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
