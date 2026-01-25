extends Camera3D
class_name PlayerCamera

var zoom_fx_disabled:= false

var fov_tween: Tween
var forward_tween: Tween
var base_forward: float
var base_fov: float


func _ready() -> void:
	base_forward = position.z
	base_fov = fov


func forward_zoom_fx(amount: float = 0.08, duration: float = 0.2):
	if zoom_fx_disabled:
		return
	
	if Find.P().is_moving:
		return
	
	if forward_tween and forward_tween.is_running():
		forward_tween.stop()
		forward_tween.kill()
	
	forward_tween = create_tween()
	
	var start_position:= base_forward
	var target_position:= base_forward - amount
	
	forward_tween.tween_property(self, "position:z", target_position, duration * 0.5)\
		.from(start_position)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	forward_tween.tween_property(self, "position:z", start_position, duration * 0.5)\
		.from(target_position)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)


func fov_zoom_fx(amount: float = 2.5, duration: float = 0.15):
	if zoom_fx_disabled:
		return
	
	if fov_tween and fov_tween.is_running():
		fov_tween.kill()
	
	fov_tween = create_tween()
	
	var start_fov:= base_fov
	var target_fov:= base_fov - amount
	
	fov_tween.tween_property(self, "fov", target_fov, duration * 0.5)\
		.from(start_fov)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	fov_tween.tween_property(self, "fov", start_fov, duration * 0.5)\
		.from(target_fov)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
