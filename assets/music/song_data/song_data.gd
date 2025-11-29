extends Resource
class_name SongData

@export var name:= "Name"
@export var author:= "Author"
@export var bpm:= 120
@export var volume:= 0.0
@export_file_path var file_path:= ""
@export_file_path() var chords_midi_path:= ""
@export var bpm_changes: Dictionary[float, int] = {}
@export var key:= ""
@export var cover_art_path:= ""
