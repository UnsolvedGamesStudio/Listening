extends Node

## Beat Visualizer
var active_circles: Array[TimingCircle] = []


## Spells
enum elements {FIRE, ICE, LIGHTNING}

var element_container: Array[String] = []
var last_element:= "none"
