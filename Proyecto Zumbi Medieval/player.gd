extends CharacterBody3D

const JUMP_VELOCITY = 3
const SPEED = 7
const SHIFT_MULTIPLIER = 2.5

var rotation_speed = 5.0  
@onready var animation = $AnimationPlayer
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var direcion = Vector3.ZERO
var jump = false

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

	faceDirection(delta)
	Action()
	Attack(randi_range(10,30))
	HUD()

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
	
	input_vector = input_vector.normalized()
	velocity.x = input_vector.x * SPEED
	velocity.z = input_vector.z * SPEED

	if jump == false:
		animation.speed_scale = 1
		if velocity.length() != 0 and is_on_floor():
			animation.play("Run")
		elif  not is_on_floor():
			animation.play("Salto")
			jump = true
		else:
			animation.play("Idle")
	if is_on_floor() and jump == true:
		animation.play("Salto_suelo")
		velocity = Vector3.ZERO

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

func  HUD():
#region GUI Test Estado
#Detectando estados de botones
	$Estado/Label.text = "direcion" + str(direcion)
	$Estado/Label2.text = "direcion.length()  = " + str(direcion.length())
	$Estado/Label3.text = "FPS: " + str(Engine.get_frames_per_second())
	$Estado/Label4.text = "Velocidad " + str(velocity)
	$Estado/Label5.text = "Velocidad.Length()  = " + str(velocity.length())

	if  Engine.get_frames_per_second() <= 24:
		$Estado/Label3.text = "FPS: " + str(Engine.get_frames_per_second()) + " Inestables"
		$Estado/Label3.modulate = Color(1, 0, 0, 1)
	else:
		$Estado/Label3.text = "FPS: " + str(Engine.get_frames_per_second()) + " Estables"
		$Estado/Label3.modulate = Color(1, 1, 1, 1)
		
func  _input(event):
	if event is InputEventKey:
		if event.as_text() == "W" or event.as_text() == "S" or event.as_text() == "D" or event.as_text() == "A" or event.as_text() == "Space":
			if event.pressed:
				get_node("Estado/" + event.as_text()).color = Color("db0100f3")
			else:
				get_node("Estado/" + event.as_text()).color = Color("ffffff")

#endregion


func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"Salto":
			if is_on_floor():
				animation.play("Salto_suelo")
				animation.speed_scale = 3
			else:
				animation.play("Salto_aire")
		"Salto_aire":
			animation.play("Salto_suelo")
			animation.speed_scale = 3
		"Salto_suelo":
			jump = false
