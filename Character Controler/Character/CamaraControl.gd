extends Node3D

var player 
@export var sencivilidad : int = 5
var camara : bool = true
@export var Aceleracio : int = 15
var joy : bool = false
var MovCam

func _ready():
	pass
	
func _input(event):
	if camara == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseMotion:
		if camara == true and joy == false:
			rotation.x -= event.relative.y /1000 * sencivilidad
			rotation.y -= event.relative.x /1000 * sencivilidad
			rotation.x = clamp(rotation.x, deg_to_rad(-60),deg_to_rad(20))
		#Fase en prueba [errores por doquier]
		if joy == true:
			MovCam = (Vector3(int(Input.is_action_pressed("L")) - int(Input.is_action_pressed("J")), 
				0, int(Input.is_action_pressed("K")) - int(Input.is_action_pressed("I"))))
			rotation.x -= MovCam.x /1000 * sencivilidad
			rotation.y -= MovCam.y /1000 * sencivilidad
			rotation.x = clamp(rotation.x, deg_to_rad(-60),deg_to_rad(20))
			
			
func _process(_delta):
	if Global.Camara == 1:
		$SpringArm3D/Camera3D.current = true
	else:
		$SpringArm3D/Camera3D.current = false
	
	rotation_degrees.y = lerp(rotation_degrees.y, rad_to_deg(rotation.y), _delta * Aceleracio)
	rotation_degrees.x = lerp(rotation_degrees.x, rad_to_deg(rotation.x), _delta * Aceleracio)
	
	player = get_tree().get_nodes_in_group("Player")[0]
	global_position = player.global_position
	$SpringArm3D/Camera3D.look_at(player.get_node("LookAt").global_position)
	
	if Input.is_action_just_pressed("Prueba"):
		print(rotation.x)

	if  Input.is_action_just_pressed("M"):
		camara = !camara
		print(camara)
		
