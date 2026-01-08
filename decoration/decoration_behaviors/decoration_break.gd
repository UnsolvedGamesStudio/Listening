extends Area3D


func _ready() -> void:
	area_entered.connect(on_area_entered)


func on_area_entered(area: Area3D):
	print(area)
	if owner.has_method("on_break"):
		owner.on_break()
