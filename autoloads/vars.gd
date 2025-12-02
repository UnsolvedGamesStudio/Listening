extends Node
## Todo: rework instrument manager
var paused:= false
var level_time:= 0.0


var total_neurons:= 0
var neurons:= get_collected("synapses")
var total_synapses:= 0
var synapses:= get_collected("synapses")
var max_dopamine:= 100.0:
	set(value):
		max_dopamine = clampf(value, 0.0, 9999.9)
var dopamine:= max_dopamine / 2.0:
	set(value):
		dopamine = clampf(value, 0.0, max_dopamine)

## Player
var interact_range:= 4.0

## Instruments
enum instrument_types {LUTE, CARILLON}
var current_instrument:= instrument_types.LUTE

## Layout Todo: Convert to enum
const DIRECTIONS: Dictionary[String, Vector3i] = {
	"north" : Vector3i(0, 0, -1),
	"east" : Vector3i(1, 0, 0),
	"south" : Vector3i(0, 0, 1),
	"west" : Vector3i(-1, 0, 0),
	"up" : Vector3i(0, 1, 0),
	"down" : Vector3i(0, -1, 0)
}

var cell_nodes: Array[Cell] = []

var forgetters: Array[Forgetter] = []

## Grid
const cell_size:= 2.0

var player_spawn_cell: Cell
var player_cell: Cell

## Floor Info
var floor_heights: Dictionary[int, float] = {} ## Floor number : Floor height


## Beat Visualizer
var combo:= 0
var score:= 0.0
var beat_circle_offset:= 0.0
var active_circles: Array[TimingCircle] = []
var last_activated_circle: TimingCircle
var in_timing_window:= false


## Spells
var elements: Array[Resource] = [
	preload("res://player/spell_casting/elements/joy.tres"),
	preload("res://player/spell_casting/elements/sadness.tres"),
	preload("res://player/spell_casting/elements/anger.tres"),
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
	TriggersManager.to_die_ids.clear()
	paused = false
	level_time = 0.0
	cell_nodes.clear()
	floor_heights.clear()
	player_cell = null
	combo = 0
	score = 0.0
	active_circles.clear()
	last_activated_circle = null
	element_container.clear()
	last_element = "none"
	living_enemies.clear()
	synapses = get_collected("synapses")
	total_synapses = get_collected("synapses")
	neurons = get_collected("neurons")
	total_neurons = get_collected("neurons")
	inventory.clear()


func get_collected(category: String) -> int:
	return SaveManager.saved_data[category].size()
