extends VBoxContainer

const INVENTORY_UI_ITEM = preload("uid://kpvoeykhbpv1")


func _ready() -> void:
	Bus.item_picked_up.connect(on_item_picked_up)
	Bus.item_removed.connect(on_item_removed)



func create_texture_rect(item: Vars.item_types):
	var new_rect: TextureRect = INVENTORY_UI_ITEM.instantiate()
	new_rect.texture = Vars.inventory[item]["texture"]
	new_rect.get_child(0).text = str("x", Vars.inventory[item]["amount"])
	add_child(new_rect)


func on_item_removed(item: Vars.item_types):
	for child in get_children():
		if not child.texture == Vars.inventory[item]["texture"]:
			return
		
		child.get_child(0).text = str("x", Vars.inventory[item]["amount"])
		
		if Vars.inventory[item]["amount"] <= 0:
			child.queue_free()


func on_item_picked_up(item: Vars.item_types):
	for child in get_children():
		child.queue_free()
	
	for inventory_item in Vars.inventory:
		create_texture_rect(item)
