extends MeshInstance3D

@onready var fake_dungeon_visible: VisibleOnScreenNotifier3D = %FakeDungeonVisible


func _process(delta: float) -> void:
	if fake_dungeon_visible.is_on_screen() == false:
		queue_free()
