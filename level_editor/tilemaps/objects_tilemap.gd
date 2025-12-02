@tool
extends TileMapLayer
## Unused, to be used when needing a reference from placing them outside the tilemap
@export_tool_button("Generate uuid") var generate_uuid = _generate_uuid_v4


func _generate_uuid_v4() -> String:
	var return_value:= ""
	
	var p1 = _generate_hex_bytes(4)
	var p2 = _generate_hex_bytes(2)
	var p3 = _generate_hex_bytes(2)
	var p4 = _generate_hex_bytes(2)
	var p5 = _generate_hex_bytes(6)
	
	return_value = p1 + "-" + p2 + "-" + p3 + "-" + p4 + "-" + p5
	print(return_value)
	return return_value


func _generate_hex_bytes(byte_count: int) -> String:
	var return_value:= ""
	var buf = PackedByteArray()
	buf.resize(byte_count)
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for i in range(byte_count):
		buf[i] = rng.randi() & 0xFF
	
	return_value = buf.hex_encode()
	return return_value


func _on_changed() -> void:
	pass # Replace with function body.
