extends CharacterBody3D

var eNet = ENetMultiplayerPeer.new()


#se declaran variables de movimiento del player
@export var SPEED : float = 5.0
@export var JUMP_VELOCITY : float = 4.5
@export var Angular_Speed :int = 10
var direction : Vector3 = Vector3(0,0,1)
var Mode_attack : bool = false
var Inputvector : Vector3

# se hace un llamado a la gravedad del motor
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#Aqui se refferencian los nodos
@onready var camera : Node = $Camara_Ctrl
@onready var player_mesh : Node = $Cuerpo
@onready var radioVector: Node = $Camara_Ctrl/RadioVector

# variables para el movimiento de camara
@export var Speed_Track : float = 0.5

#Estas son las variables para las armas
@onready var Gun : Node = $Cuerpo/cara/Gun
var Bullet = load("res://Bullets/Bullet.tscn")
@onready var direction_bullet :Node = $Origin_poitn/direction_bullet
@onready var origin_poitn :Node = $Origin_poitn
var Contador_1 = 0
var Contador_2 = 8

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	LoggData.info(str(name.to_int()))

func _physics_process(delta):
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("T"):
			Mode_attack = !Mode_attack
			print(Mode_attack)
#region Mecanicas de un disparo
		origin_poitn.rotation_degrees.y = player_mesh.rotation_degrees.y
		if Input.is_action_just_pressed("Click") and Contador_1 <= 0:
			Contador_1 = Contador_2 * delta
			var bullet = Bullet.instantiate()
			bullet.direction = direction_bullet.global_position - player_mesh.global_position
			bullet.direction.y = 0
			get_parent().add_child(bullet)
			bullet.rotation_degrees.y = player_mesh.rotation_degrees.y - 90
			#bullet.transform.basis.y = player_mesh.transform.basis.y
			bullet.global_position = Gun.global_position
		if Contador_1 > 0:
			Contador_1 -= delta
#endregion

#region Player Movement
	# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta
	# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		Inputvector = (Vector3(int(Input.is_action_pressed("A")) - int(Input.is_action_pressed("D")), 
				0, int(Input.is_action_pressed("W")) - int(Input.is_action_pressed("S"))))
		if Inputvector:
			direction = Inputvector
				#Vector unitario
			var rotacionPlayer: float = radioVector.global_transform.basis.get_euler().y
			direction = direction.rotated(Vector3.UP, rotacionPlayer)
			direction = direction.normalized() * -1
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		move_and_slide()
	# Rotando la maya esta pequeña parte se cambiara por face direccion
		if Mode_attack == false:
			player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(direction.x, direction.z), delta * Angular_Speed)
		else:
			pass
			direction = faceDirection(delta)
		Attack(randi_range(10,30))
#endregion

#region camara Control
	camera.top_level = true
	camera.global_position.z = lerp(camera.global_position.z, self.global_position.z, Speed_Track * delta)
	camera.global_position.x = lerp(camera.global_position.x, self.global_position.x, Speed_Track * delta)
#endregion

#region DEBUG GUI
	$Estado/Label.text = "direcion" + str(direction)
	$Estado/Label2.text = "direcion.length()  = " + str(direction.length())
	$Estado/Label3.text = "FPS: " + str(Engine.get_frames_per_second())
	$Estado/Label4.text = "Velocidad " + str(velocity)
	$Estado/Label5.text = "Velocidad.Length()  = " + str(velocity.length())
	$Estado/Label6.text = str("Direccion de disparo: ", direction_bullet.global_position.normalized())

	if  Engine.get_frames_per_second() <= 24:
		$Estado/Label3.text = "FPS: " + str(Engine.get_frames_per_second()) + " Inestables"
		$Estado/Label3.modulate = Color(1, 0, 0, 1)
	else:
		$Estado/Label3.text = "FPS: " + str(Engine.get_frames_per_second()) + " Estables"
		$Estado/Label3.modulate = Color(1, 1, 1, 1)
		
func  _input(event):
	if event is InputEventKey:
		if event.as_text() == "W" or event.as_text() == "S" or event.as_text() == "D" or event.as_text() == "A" or event.as_text() == "C" or event.as_text() == "Space":
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
	if is_multiplayer_authority():
		var Camera = $Camara_Ctrl/Camera3D
		var mouse_position = get_viewport().get_mouse_position()
		var ray_direction = Camera.project_ray_normal(mouse_position)
		var Camera_origin = Camera.global_transform.origin
		var base_ray = ray_direction.normalized()
		var s = -Camera_origin.y / base_ray.y
		var intersection_point = Camera_origin + base_ray * s
		var target_direction = (intersection_point - global_transform.origin).normalized()
		target_direction.y = 0
		#var look_rotation = Basis().looking_at(target_direction, Vector3(0, 1, 0),false)
		#global_transform.basis = global_transform.basis.slerp(look_rotation, Angular_Speed * delta)
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(target_direction.x, target_direction.z), delta * Angular_Speed)
		return target_direction
	
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








