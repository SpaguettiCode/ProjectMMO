extends CharacterBody3D

#se declaran variables de movimiento del player
@export var SPEED : float = 5.0
@export var JUMP_VELOCITY : float = 4.5
@export var Angular_Speed :int = 5
var direction : Vector3 = Vector3.ZERO
var Mode_attack : bool = false

# se hace un llamado a la gravedad del motor
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#Aqui se refferencian los nodos
@onready var camara : Node = $Camara_ctrl
@onready var player_mesh : Node = $Cuerpo
@onready var radioVector: Node = $Camara_ctrl/Camera3D

# variables para el movimiento de camara
@export var Speed_Track : float = 0.5

func _physics_process(delta):
	if Input.is_action_just_pressed("T"):
		Mode_attack = !Mode_attack
		print(Mode_attack)

#region Player Movement
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("D") or Input.is_action_pressed("A") or Input.is_action_pressed("S") or Input.is_action_pressed("W"):
			#Vector unitario
		var _rotacionPlayer: float = radioVector.global_transform.basis.get_euler().y
		direction = (Vector3(int(Input.is_action_pressed("D")) - int(Input.is_action_pressed("A")), 
				0, int(Input.is_action_pressed("S")) - int(Input.is_action_pressed("W"))))
		direction = direction.rotated(Vector3.UP, _rotacionPlayer).normalized()
		direction = direction.normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
	# Rotando la maya esta peueña parte se cambiara por face direccion
	if Mode_attack == false:
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(direction.x, direction.z) - deg_to_rad(180), delta * Angular_Speed)
	else:
		pass
		faceDirection(delta)
	Attack(randi_range(10,30))
#endregion
#region camara Control
	camara.global_position.z = lerp(camara.global_position.z, self.global_position.z, Speed_Track * delta)
	camara.global_position.x = lerp(camara.global_position.x, self.global_position.x, Speed_Track * delta)
#endregion

#region DEBUG GUI
	$Estado/Label.text = "direcion" + str(direction)
	$Estado/Label2.text = "direcion.length()  = " + str(direction.length())
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
				
		if event.as_text() == "T" and Mode_attack == true:
			get_node("Estado/" + event.as_text()).color = Color("db0100f3")
			$Estado/T/Label.text = "Combat Mode"
		if Mode_attack == false and event.as_text() == "T":
			get_node("Estado/" + event.as_text()).color = Color("00ff00")
			$Estado/T/Label.text = "Normal Mode"
#endregion

func faceDirection(delta):
	var camera = $Camara_ctrl/Camera3D
	var mouse_position = get_viewport().get_mouse_position()
	var ray_direction = camera.project_ray_normal(mouse_position)
	var camera_origin = camera.global_transform.origin
	var base_ray = ray_direction.normalized()
	var s = -camera_origin.y / base_ray.y
	var intersection_point = camera_origin + base_ray * s
	var target_direction = (intersection_point - global_transform.origin).normalized()
	target_direction.y = 0
	#var look_rotation = Basis().looking_at(target_direction, Vector3(0, 1, 0),false)
	#global_transform.basis = global_transform.basis.slerp(look_rotation, Angular_Speed * delta)
	player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(target_direction.x, target_direction.z) - deg_to_rad(180), delta * Angular_Speed)
	
func Action_AttackMode():
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

	move_and_slide()

func Attack(dammage):
	if Input.is_action_just_pressed("Atacar"):
		var camera = $Camara_ctrl/Camera3D
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
