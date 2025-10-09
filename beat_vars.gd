extends Node


var song_position:= 0.0
var song_position_in_beats:= 1
var seconds_per_beat:= 60.0 / 120
var last_reported_beat:= -1
var beats_before_start:= 0
var current_measure:= 1

var closest:= 0

var frames_since_last_beat:= 0
