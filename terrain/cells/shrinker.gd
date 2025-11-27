extends Area3D
class_name ShrinkerCell
## Todo: Fix some enemies being very hard to hit properly while shrunk
@export var cell: Cell

func _ready() -> void:
	area_entered.connect(on_area_entered)


func shrink(area: Area3D):
	if check_elligible(area) == false:
		return
	
	var cell_height:= cell.max_player_height
	
	if cell_height > 1.0:
		return
	
	area.owner.scale = Vector3(cell_height, cell_height, cell_height)


func check_elligible(area: Area3D):
	if area.owner is Enemy:
		return true
	
	if area.owner is Pickup:
		return true
	
	return false


func on_area_entered(area: Area3D):
	shrink(area)
