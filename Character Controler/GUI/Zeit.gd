extends CharacterBody3D

var direcion = Vector3.ZERO
var SPEED : float
var vel = 2
const  JUMP_VELOCITY = 2
var aceleracion = 3
var aceleracion_angular = 6
var estado  = 0

@onready var radioVector = $CamaraRoot/RadioVector
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func  _ready():
	velocity = Vector3.ZERO


func _physics_process(_delta):

#region Aqui va todo lo relacionado a movimiento en primera persona
	if Global.Camara == 2:
		$Zeit_Rig/Skeleton3D/Zeit.visible = false
		$Zeit_Rig/Skeleton3D/Cuello.visible = false
		$Zeit_Rig/Skeleton3D/Ojos.visible = false
	else:
		$Zeit_Rig/Skeleton3D/Zeit.visible = true
		$Zeit_Rig/Skeleton3D/Cuello.visible = true
		$Zeit_Rig/Skeleton3D/Ojos.visible = true
#endregion

#region Aqui va todo lo relacionado a movimiento en tercera persona
	if Global.Camara == 1:
		if not is_on_floor():
			velocity.y -= gravity * _delta
		# condicionando a cero cuando no esta colicionado con el suelo
		else:
			velocity.y = 0
			
		if Input.is_action_pressed("L") or Input.is_action_pressed("J") or Input.is_action_pressed("K") or Input.is_action_pressed("I") :
			# Rotando la maya
			$Zeit_Rig.rotation.y = lerp_angle($Zeit_Rig.rotation.y, atan2(direcion.x, direcion.z), _delta * aceleracion_angular)
			#Vector unitario
			var _rotacionPlayer = radioVector.global_transform.basis.get_euler().y
			direcion = (Vector3(int(Input.is_action_pressed("L")) - int(Input.is_action_pressed("J")), 
				0, int(Input.is_action_pressed("K")) - int(Input.is_action_pressed("I"))))
			direcion = direcion.rotated(Vector3.UP, _rotacionPlayer).normalized()
			direcion = direcion.normalized()
			velocity.x = direcion.x * SPEED 
			velocity.z = direcion.z * SPEED 
			estado = 1
			
		else:
			# condicionando a cero la velocidad cuando no se preciona nada
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			estado = 0

		# Opteniendo y calculando el salto
		if Input.is_action_just_pressed("C") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		# optniendo y calculando la rapidez de carrera
		if Input.is_action_pressed("V"):
			SPEED = vel * aceleracion
			#poniendo restricciones
			# 1) que la magnitud de el vector de direccion sea distinto a cero
			# 2) que la velocidad en y sea igual a cero, # 3) que la magnitud de la velocidad sea cero
			# condiciones que no pueden cambiar por que se bugea
			if direcion.length() != 0 and velocity.y == 0 and velocity.length() != 0:
					estado = 2
			#velocity = lerp(velocity, direcion * SPEED, _delta * aceleracion)
		# retornando la rapidez a su condicion original
		else:
			SPEED = vel
		# Calculando la velocidad de caida
		# Calculando el movimiento y desplazamiento
		move_and_slide()

	else: 
		pass
	#activando la funcion de animacion
	animacion()
#endregion

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
		if event.as_text() == "I" or event.as_text() == "K" or event.as_text() == "L" or event.as_text() == "J" or event.as_text() == "C":
			if event.pressed:
				get_node("Estado/" + event.as_text()).color = Color("db0100f3")
			else:
				get_node("Estado/" + event.as_text()).color = Color("ffffff")

#endregion


func  animacion():
	if estado == 1:
		get_node("AnimationPlayer").play("Walk")
	elif estado == 2:
		get_node("AnimationPlayer").play("Run")
	elif not is_on_floor():
		get_node("AnimationPlayer").play("Salto")
	else:
		get_node("AnimationPlayer").play("Idle")
	if Input.is_action_just_pressed("S"):
		get_node("AnimationPlayer").play("Envainar_2")
		
