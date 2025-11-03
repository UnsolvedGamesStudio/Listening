extends Node


var paused:= false
var level_time:= 0.0

## Player
var synapses_left:= 0
var synapses:= 0
var interact_range:= 4.0


## Layout
const directions: Dictionary[String, Vector3i] = {
	"north" : Vector3i(0, 0, -1),
	"east" : Vector3i(1, 0, 0),
	"south" : Vector3i(0, 0, 1),
	"west" : Vector3i(-1, 0, 0)
}

const cell_size:= 2.0
var cell_nodes: Array[Cell] = []
var cell_coordinates: Array[Vector2i] = []
var player_spawn_cell: Cell

var player_cell: Cell

var forgetters: Array[Forgetter] = []

## Beat Visualizer
var combo:= 0
var score:= 0.0
var beat_circle_offset:= 0.0
var active_circles: Array[TimingCircle] = []
var last_activated_circle: TimingCircle
var in_timing_window:= false


## Spells
var elements: Array[Resource] = [
	preload("res://spell_casting/elements/joy.tres"),
	preload("res://spell_casting/elements/anger.tres"),
	preload("res://spell_casting/elements/sadness.tres"),
]

## Spellcasting
var element_container: Array[int] = []
var last_element:= "none"

## Enemies
var living_enemies: Array[Enemy] = []


## Inventory
var inventory: Dictionary[item_types, Dictionary] = {}
enum item_types{F_KEY}


func reset():
	paused = false
	level_time = 0.0
	cell_nodes.clear()
	cell_coordinates.clear()
	player_cell = null
	combo = 0
	score = 0.0
	active_circles.clear()
	last_activated_circle = null
	element_container.clear()
	last_element = "none"
	living_enemies.clear()
	synapses = 0
	synapses_left = 0
	inventory.clear()
