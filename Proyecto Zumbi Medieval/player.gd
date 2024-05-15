extends CharacterBody3D

const JUMP_VELOCITY = 4.5
const SPEED = 7
const SHIFT_MULTIPLIER = 2.5

var rotation_speed = 5.0  
@onready var animation = $AnimationPlayer
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func CameraPos():
	$"../Camera3D".position.x = self.position.x
	$"../Camera3D".position.z = self.position.z + 10



func _ready():
	CameraPos()



func _process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
		print("not floor")
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if velocity.length() == 0:
		animation.play("Idle")
	else:
		animation.play("Run")

	faceDirection(delta)
	Action()
	Attack(randi_range(10,30))


func faceDirection(delta):
	var camera = get_tree().get_nodes_in_group("Camera")[0]
	var mouse_position = get_viewport().get_mouse_position()
	var ray_direction = camera.project_ray_normal(mouse_position)
	var camera_origin = camera.global_transform.origin
	var base_ray = ray_direction.normalized()
	var s = -camera_origin.y / base_ray.y
	var intersection_point = camera_origin + base_ray * s
	var target_direction = (intersection_point - global_transform.origin).normalized()
	target_direction.y = 0
	var look_rotation = Basis().looking_at(target_direction, Vector3(0, 1, 0),false)
	global_transform.basis = global_transform.basis.slerp(look_rotation, rotation_speed * delta)


func Action():
	var input_vector = Vector3.ZERO
	if Input.is_action_pressed("Izquierda"):
		input_vector.x -= 1
	if Input.is_action_pressed("Derecha"):
		input_vector.x += 1
	if Input.is_action_pressed("Arriba"):
		input_vector.z -= 1
	if Input.is_action_pressed("Abajo"):
		input_vector.z += 1
	$AnimationPlayer.play("Zeit_Rig|idle")

	velocity.x = input_vector.x * SPEED
	velocity.z = input_vector.z * SPEED
	CameraPos()
	move_and_slide()


func Attack(dammage):
	if Input.is_action_just_pressed("Atacar"):
		var camera = get_tree().get_nodes_in_group("Camera")[0]
		var mousePos = get_viewport().get_mouse_position()
		var rayQuery = PhysicsRayQueryParameters3D.new()
		var rayLength = 100
		var from = camera.project_ray_origin(mousePos)
		var to = from + camera.project_ray_normal(mousePos) * rayLength
		var space = get_world_3d().direct_space_state
		rayQuery.from = from
		rayQuery.to = to
		rayQuery.collide_with_areas = true
		var result = space.intersect_ray(rayQuery)
		print("Disparo en: " + str(result))
