@tool
extends Path3D

@export_tool_button("Regenerate Collision") var generate_collision_button = generate_collision

@export var static_body: StaticBody3D
@export var csg: CSGPolygon3D

@export var thickness: float = 10.0:
	set(value):
		if !csg:
			return
		
		thickness = value
		csg .polygon[0].y = -thickness
		csg .polygon[3].y = -thickness

# TODO: enum for round or straight edges

func generate_collision():
	if !get_parent().is_editable_instance(self):
		get_parent().set_editable_instance(self, true)
	clear_collision()
	regenerate_collision()


func clear_collision():
	for c in static_body.get_children():
		static_body.remove_child(c)
		c.queue_free()

func regenerate_collision():
	var collision_shape = csg.bake_collision_shape()
	collision_shape.backface_collision = true
	collision_shape.resource_local_to_scene = true
	var collision = CollisionShape3D.new()
	static_body.add_child(collision)
	collision.shape = collision_shape
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

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		# lock rotation around y
		global_rotation_degrees.y = 0.0
