extends Area3D
class_name ShrinkerCell

@export var cell: Cell

func _ready() -> void:
	area_entered.connect(on_area_entered)


func check_elligible(area: Area3D):
	if area.owner is Enemy:
		return true
	
	if area.owner is Pickup:
		return true
	
	return false


func on_area_entered(area: Area3D):
	if check_elligible(area) == true:
		if cell.max_player_height > 1.0:
			return
		
		area.owner.scale *= cell.max_player_height
		print(area.owner.scale)
