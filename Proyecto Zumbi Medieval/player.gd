extends CharacterBody3D


const SPEED = 5
const SHIFT_MULTIPLIER = 2.5
const ALT_MULTIPLIER = 1.0 / SHIFT_MULTIPLIER

var _direction = Vector3(0.0, 0.0, 0.0)
var _velocity = Vector3(0.0, 0.0, 0.0)
var _acceleration = 30
var _deceleration = -10
var _vel_multiplier = 4


var rotation_speed = 5.0  # Velocidad de rotación (ajústala según tus necesidades)

func _process(delta: float) -> void:
	faceDirection(delta)
	Action(delta)

func faceDirection(delta):
	var camera = get_tree().get_nodes_in_group("Camera")[0]
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_direction = camera.project_ray_normal(mouse_position)
	var camera_origin = camera.global_transform.origin
	var base_ray = ray_direction.normalized()
	var s = -camera_origin.y / base_ray.y
	var intersection_point = camera_origin + base_ray * s
	var target_direction = (intersection_point - global_transform.origin).normalized()
	target_direction.y = 0
	var look_rotation = Basis().looking_at(target_direction, Vector3(0, 1, 0))
	global_transform.basis = global_transform.basis.slerp(look_rotation, rotation_speed * delta)



func Action(delta):
	var input_vector = Vector3.ZERO
	if Input.is_action_pressed("Izquierda"):
		input_vector.x -= 1
	if Input.is_action_pressed("Derecha"):
		input_vector.x += 1
	if Input.is_action_pressed("Arriba"):
		input_vector.z -= 1
	if Input.is_action_pressed("Abajo"):
		input_vector.z += 1
	velocity = input_vector.normalized() * SPEED
	move_and_slide()

