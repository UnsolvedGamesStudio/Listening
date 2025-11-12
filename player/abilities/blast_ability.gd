extends PlayerAbility
class_name BlastAbility

const EXPLOSION = preload("uid://cabfwuhvqiwog")


@export var duration:= 10.0
var active:= false
var active_shell: ShellObject


func activate():
	var blast_inst: Node3D = EXPLOSION.instantiate()
	player.get_parent().add_child(blast_inst)
