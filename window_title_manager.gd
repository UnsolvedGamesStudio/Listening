extends Node
## The ones you can get could be dependent of the current emotion leaning
var possible_titles:= [
	"Don't leave me",
	"Where am I?",
	"LET'S CRUSH THEM",
	"Whatever happens happens",
	"Whatever, I'm done",
	"It's too late",
	"Feel the vibes",
	"Whoever you are, I love you",
	"It hurts",
	"Strictly speaking, this is an upgrade",
	"Sweet nothingness",
	"Float like a butterfly, sting like a butterfly",
	"Pardon me, just passing through!",
	"Show me the way out",
	"Please show me the way out",
	"Get out",
]


func _ready() -> void:
	get_window().title = possible_titles.pick_random()
