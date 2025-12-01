@tool
extends PanelContainer
class_name SongSelectButton
## Todo: Song sorting system (default: bpm)
## Todo: Reference the song data in Bgm, and read from it when starting the level
@onready var name_label: Label = %NameLabel
@onready var selection_outline: PanelContainer = %SelectionOutline
@onready var bpm_label: Label = %BpmLabel
@onready var author_label: Label = %AuthorLabel
@onready var progress_bar: ProgressBar = %ProgressBar

static var selected_song: SongSelectButton

@export var song_data: SongData = preload("res://assets/music/song_data/so_simple.tres")
@export var default:= false

var song_preview: AudioStreamPlayer
var song_stream: AudioStream


func _ready() -> void:
	song_preview = get_tree().get_first_node_in_group("prep_screen_song_preview")
	song_stream = load(song_data.file_path)
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	
	name_label.text = song_data.name
	bpm_label.text = str("BPM: ", song_data.bpm)
	author_label.text = str("By ", song_data.author)
	
	if default == true:
		selected_song = self
		apply_values()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if song_preview.stream == song_stream:
		update_progress_bar()
	else:
		progress_bar.value = 0.0
	
	if selected_song == self:
		selection_outline.show()
		return
	
	selection_outline.hide()


func update_progress_bar():
	if song_preview.playing == true:
		progress_bar.max_value = song_preview.stream.get_length()
		progress_bar.value = song_preview.get_playback_position()
	
	else:
		progress_bar.value = 0.0


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("cast"):
		on_clicked()


func apply_values():
	Bgm.stream = song_stream
	Bgm.volume_db = song_data.volume
	Bgm.rhythm_notifier.bpm = song_data.bpm
	Bgm.midi_player.file = song_data.chords_midi_path


func on_clicked():
	selected_song = self
	GlobalSfx.ui_click.play()
	apply_values()


func on_mouse_entered():
	if not selected_song == self:
		scale.y = 1.1
	
	GlobalSfx.ui_hover.play()
	song_preview.volume_db = song_data.volume
	song_preview.stream = song_stream
	song_preview.play()


func on_mouse_exited():
	if not selected_song == self:
		scale.y = 1.0
	
	song_preview.stop()
