@tool
extends Path3D

@export_tool_button("Regenerate Collision") var generate_collision_button = _generate_collision

@export var material: StandardMaterial3D:
	set(value):
		if !csg_combiner:
			return
		material = value
		csg_combiner.material_override = material

@export var static_body: StaticBody3D
@export var csg_combiner: CSGCombiner3D
@export var csg_polygon: CSGPolygon3D

@export var thickness: float = 10.0:
	set(value):
		if !csg_polygon:
			return
		
		thickness = value
		csg_polygon.polygon[0].y = -thickness
		csg_polygon.polygon[3].y = -thickness
		_update_edge_parameter()

@export_group("Edge", "edge")
@export var edge_type: Edges = Edges.Flat:
	set(value):
		if !csg_combiner:
			return
		if !is_inside_tree():
			return
		
		edge_type = value
		match edge_type:
			Edges.Flat:
				_generate_flat_edges()
			Edges.Round:
				_generate_round_edges()
		_generate_collision()

@export var edge_update_with_line_thickness: bool = true:
	set(value):
		if !csg_combiner:
			return
		if !is_inside_tree():
			return
		edge_update_with_line_thickness = value
		if edge_type == Edges.Round:
			_update_edge_parameter()

@export var edge_extra_thickness: float:
	set(value):
		if !csg_combiner:
			return
		if !is_inside_tree():
			return
		edge_extra_thickness = value
		if edge_type == Edges.Round:
			_update_edge_parameter()

@export var edge_translation: Vector2:
	set(value):
		if !csg_combiner:
			return
		if !is_inside_tree():
			return
		edge_translation = value
		if edge_type == Edges.Round:
			_update_edge_parameter()


enum Edges {
	Flat,
	Round,
}

func _generate_flat_edges():
	# remove the two csg_combiner cylinder shapes
	for c in csg_combiner.get_children():
		if c is CSGCylinder3D:
			csg_combiner.remove_child(c)
			c.queue_free()

func _generate_round_edges():
	var cylinder_left = CSGCylinder3D.new()
	var cylinder_right = CSGCylinder3D.new()
	csg_combiner.add_child(cylinder_left)
	csg_combiner.add_child(cylinder_right)
	if Engine.is_editor_hint():
		cylinder_left.owner = get_tree().edited_scene_root
		cylinder_right.owner = get_tree().edited_scene_root
	
	_update_edge_parameter()

func _update_edge_parameter():
	if edge_type != Edges.Round:
		return
	var cylinder = csg_combiner.get_children().filter(func(c): return c is CSGCylinder3D)
	var cylinder_left = cylinder[0] as CSGCylinder3D
	var cylinder_right = cylinder[1] as CSGCylinder3D
	
	cylinder_left.height = 4.0
	cylinder_right.height = 4.0
	cylinder_left.sides = 64
	cylinder_right.sides = 64
	cylinder_left.rotation_degrees.z = 90.0
	cylinder_right.rotation_degrees.z = 90.0
	
	# position
	var right_point = curve.get_point_position(curve.point_count - 1)
	var left_point = curve.get_point_position(0)
	cylinder_right.position.z = right_point.z + edge_translation.x
	cylinder_left.position.z = left_point.z + edge_translation.x
	cylinder_right.position.y = right_point.y - thickness / 2.0 + edge_translation.y
	cylinder_left.position.y = left_point.y - thickness / 2.0 + edge_translation.y
	
	# thickness
	var calc_thickness = thickness / 2.0 if edge_update_with_line_thickness else edge_extra_thickness
	cylinder_right.radius = calc_thickness
	cylinder_left.radius = calc_thickness
	
	# shadow
	cylinder_right.cast_shadow = false
	cylinder_left.cast_shadow = false
	cylinder_right.flip_faces = true
	cylinder_left.flip_faces = true

func _generate_collision():
	if Engine.is_editor_hint():
		if !get_parent().is_editable_instance(self):
			get_parent().set_editable_instance(self, true)
		_clear_collision()
		_update_edge_parameter()
		_regenerate_collision()

func _clear_collision():
	for c in static_body.get_children():
		static_body.remove_child(c)
		c.queue_free()

func _regenerate_collision():
	var collision_shape = csg_combiner.bake_collision_shape()
	collision_shape.backface_collision = true
	collision_shape.resource_local_to_scene = true
	var collision = CollisionShape3D.new()
	static_body.add_child(collision)
	collision.shape = collision_shape
	if Engine.is_editor_hint():
		collision.owner = get_tree().edited_scene_root

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

#func _process(_delta: float) -> void:
	#if Engine.is_editor_hint():
		## lock rotation around y
		#global_rotation_degrees.y = 0.0
