extends Node

var cell_size:= 2


## Layout
var directions: Dictionary[String, Vector3i] = {
	"north" : Vector3i(0, 0, -1),
	"east" : Vector3i(1, 0, 0),
	"south" : Vector3i(0, 0, 1),
	"west" : Vector3i(-1, 0, 0)
}


var cell_nodes: Array[Cell] = []
var cell_coordinates: Array[Vector2i] = []
var player_cell: Cell


## Beat Visualizer
var combo:= 0
var score:= 0.0
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
