extends Resource
class_name SongData

@export var name:= "Name"
@export var author:= "Author"
@export var bpm:= 120
@export var volume:= 0.0
@export var file_path:= ""
@export var chords_midi_path:= ""
@export var bpm_changes: Dictionary[float, int] = {}
@export var key:= ""
@export var cover_art_path:= ""
