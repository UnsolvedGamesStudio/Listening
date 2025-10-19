extends Node

var cell_size:= 2


## Layout
var cell_nodes: Array[Cell] = []


## Beat Visualizer
var active_circles: Array[TimingCircle] = []
var last_activated_circle: TimingCircle


## Spells
var elements: Array[Resource] = [
	preload("res://spell_casting/elements/joy.tres"),
	preload("res://spell_casting/elements/anger.tres"),
	preload("res://spell_casting/elements/sadness.tres"),
]

var element_container: Array[int] = []
var last_element:= "none"
