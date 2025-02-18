@tool
extends Path3D

func _on_curve_changed() -> void:
	if not curve:
		return
	for i in curve.point_count:
		var pos = curve.get_point_position(i)
		var _in = curve.get_point_in(i)
		var _out = curve.get_point_out(i)
		if pos.x != 0:
			curve.set_point_position(i, Vector3(0, pos.y, pos.z))
		if _in.x != 0:
			curve.set_point_in(i, Vector3(0, _in.y, _in.z))
		if _out.x != 0:
			curve.set_point_out(i, Vector3(0, _out.y, _out.z))
