extends MeshInstance3D
class_name ParallaxLayer3D

const SPEED_SCALE: float = 0.0001
const DIMENSIONS: Vector2 = Vector2(1920, 1080)
const LAYER_OFFSET: int = 50

@export var texture: Texture2D
@export var enabled := true
## The higher, the farther away from the camera. Lower value means it gets rendered
## before everything else.
## Maximum 50 layer
@export var layer: int = 1
## ignore camera movement and use at a constant speed regardless of direction.
## good for dynamic backkground effect like birds
@export var constant_speed: bool = false
## not influenced by camera speed or anything
@export var far_away: bool = false
@export_range(0, 50, 0.1) var speed := 1.0

@onready var camera: PlayerCamera = get_viewport().get_camera_3d()

var scaling_factor: float = 0.00058
var start_pos := Vector3.ZERO
var current_offset: float = 0.0
var last_camera_pos: Vector3 = Vector3.ZERO

func _ready() -> void:
	var mat = StandardMaterial3D.new()
	mat.set("albedo_texture", texture)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.surface_set_material(0, mat)
	scale.y = camera.distance * DIMENSIONS.y * scaling_factor
	scale.z = camera.distance * DIMENSIONS.x * scaling_factor
	global_position.x = LAYER_OFFSET - layer

func _physics_process(delta: float) -> void:
	if constant_speed:
		current_offset -= (speed * SPEED_SCALE)
		if !far_away:
			current_offset += _get_camera_speed() * 0.0005
	else:
		current_offset = (start_pos.z - camera.global_position.z) * (speed * SPEED_SCALE)
	
	mesh.surface_get_material(0).set("uv1_offset", Vector3(current_offset, 0.0, 0.0))
	
	last_camera_pos = camera.global_position

func _process(delta: float) -> void:
	global_position.z = camera.global_position.z
	global_position.y = camera.global_position.y + camera.height

func _get_camera_speed() -> float:
	var cam_pos = Vector3(0, 0, camera.global_position.z)
	var last_pos = Vector3(0, 0, last_camera_pos.z)
	var direction = cam_pos.direction_to(last_pos)
	return (cam_pos - last_pos).length() * direction.normalized().z
