extends Node3D


func start_level():
	Filters.fade.play("fade_in")
	await Filters.fade.animation_finished
	Bgm.bus = "BGM"
	
	if Bgm.playing == false:
		Bgm.start_song()
