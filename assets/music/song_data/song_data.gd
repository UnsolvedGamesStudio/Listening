extends Resource
class_name SongData

@export var name:= "Name"
@export var author:= "Author"
@export var bpm: int = 120
@export var volume: float = 0.0
@export_file_path var file_path:= ""
@export_file_path() var chords_midi_path:= ""
@export var start_of_loop: float = -1.0 ##(In seconds) | Leave at -1.0 to disable looping mid-song (time is typically right after the intro)
@export var bpm_changes: Dictionary[float, int] = {}
@export var key:= ""
@export var cover_art_path:= ""
