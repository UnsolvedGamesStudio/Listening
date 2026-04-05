extends AudioStreamPlayer
## Todo: Make played octave relative to a default rather than copying the midi
## Todo: Make score damage mult have dimin returns
@onready var beat_timer: BeatTimer = %BeatTimer
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
var beat_visualizer: BeatVisualizer

var current_song_data: SongData

var current_midi_notes:= []
var default_chord:= [["E", 4], ["G#", 4], ["B", 4]]
var beat_count:= 0
var last_timing:= 0.0
var circles_are_in:= false

var event_history: Dictionary[float, int] = {}


func _ready() -> void:
	var main = get_tree().get_first_node_in_group("main_scene")
	
	current_song_data = main.default_song
	
	beat_timer.beat.connect(on_beat)
	beat_timer.sub_tick.connect(on_sub_tick)
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
	
	Bus.song_started.emit()
	
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
	beat_timer.bpm = current_song_data.bpm
	midi_player.file = current_song_data.chords_midi_path
	volume_db += current_song_data.volume_modifier


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
	var chord:= default_chord
	
	if get_notes() != []:
		chord = get_notes()
	else:
		print("Using default chord")
	
	var sample:= sampler_instrument.samples[0]
	
	sampler_instrument.stop()
	
	if elements == []:
		play_single_note(chord.pick_random(), 2)
		return
	
	if elements.size() == 3:
		play_full_chord(chord)
		return
	
	var played_notes:= 0
	
	for element in elements:
		if element == 0:
			play_highest_note(chord)
		
		if element == 1:
			play_lowest_note(chord)
		
		if element == 2:
			play_middle_note(chord)
		
		played_notes += 1


func play_lowest_note(chord: Array):
	var note_to_play: Array = chord[0]
	play_single_note(note_to_play)


func play_highest_note(chord: Array):
	var note_to_play: Array = chord[-1]
	play_single_note(note_to_play)


func play_middle_note(chord: Array):
	var current_notes := chord
	var count := current_notes.size()
	
	if count == 0:
		return
	
	var idx:= (count - 1) / 2.0
	
	if count % 2 == 0:
		# even → two middle elements → random tie-breaker
		idx += randi() % 2
	
	var note_to_play = current_notes[idx]
	
	play_single_note(note_to_play)


#func play_note_no_music(elements):
	##var note_names:= ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
	##var c_maj:= ["C", "D", "E", "F", "G", "A", "B"]
	#var b_melodic_min:= ["B", "C#", "D", "E", "F#", "G#", "A#"]
	#var sample:= sampler_instrument.samples[0]
	#
	#if elements == []:
		#sampler_instrument.play_note(b_melodic_min.pick_random(), sample.octave + 1)
	#
	#if elements.size() == 3:
		#sampler_instrument.play_note("B", sample.octave)
		#sampler_instrument.play_note("E", sample.octave)
		#sampler_instrument.play_note("G#", sample.octave)
		#return
	#
	#for element in elements:
		#if element == 0:
			#sampler_instrument.play_note("B", sample.octave)
		#if element == 1:
			#sampler_instrument.play_note("E", sample.octave)
		#if element == 2:
			#sampler_instrument.play_note("G#", sample.octave)


func play_single_note(note, octave_modifier: int = 0):
	var sample:= sampler_instrument.samples[0]
	var exception_octave:= 0
	
	if Vars.current_instrument == Vars.instrument_types.CARILLON:
		exception_octave = 5
	
	sample.tone = note[0]
	sample.octave = note[1] - exception_octave + octave_modifier - 1
	
	if sample.octave < 0:
		sample.octave = 0
	
	sampler_instrument.play_note(sample.tone, sample.octave)


func play_full_chord(chord: Array, octave_modifier: int = 0):
	var sample:= sampler_instrument.samples[0]
	
	for note in chord:
		play_single_note(note, octave_modifier)


func check_accuracy(punished_for_bad_timing:= false):
	if beat_visualizer == null:
		return "perfect"
	
	var accuracy:= "missed"
	var level:= 0
	
	var easy_dist:= 10.5
	var medium_dist:= 6.5
	var perfect_dist:= 3.5
	
	var closest_results: Array = beat_visualizer.get_closest_circle()
	
	var closest_circle: TimingCircle = closest_results[0]
	var circle_dist: float = closest_results[1]
	
	if circle_dist <= easy_dist:
		accuracy = "easy"
		level = 1
	
	if circle_dist <= medium_dist:
		level = 2
		accuracy = "medium"
	
	if circle_dist <= perfect_dist:
		level = 3
		accuracy = "perfect"
	
	beat_visualizer.generate_text(accuracy)
	
	if not accuracy == "missed":
		play_correct_chime(true)
		Bus.beat_success.emit(level)
		Vars.last_activated_circle = closest_circle
		closest_circle.recolor(level)
		
		var player: Player = Find.P()
		if player:
			player.camera.forward_zoom_fx(0.03 * (level * 0.5), 0.3)
	
	if accuracy == "missed" and punished_for_bad_timing == true:
		play_correct_chime(false)
		Bus.beat_failure.emit()
	
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
	kick.stop()
	kick.play()


func on_beat(beat_index, is_catch_up: bool):
	if Vars.paused == false:
		beat_count += 1
	
	Bus.beat.emit(beat_count)


func on_sub_tick(sub_index, is_catch_up: bool):
	@warning_ignore("integer_division")
	if sub_index % (beat_timer.SUBDIVISIONS / 2) == 0:
		Bus.half_beat.emit()
	
	Bus.sub_tick.emit(sub_index)
