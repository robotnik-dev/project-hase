@tool
extends Path3D

func _ready() -> void:
	var polygon = get_child(0) as CSGPolygon3D
	polygon.use_collision = true

func _enter_tree() -> void:
	if not is_connected("curve_changed", _on_curve_changed):
		curve_changed.connect(_on_curve_changed)
	else:
		curve_changed.disconnect(_on_curve_changed)

func _on_curve_changed() -> void:
	if not curve:
		return
	
	curve.resource_local_to_scene = true
	
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
