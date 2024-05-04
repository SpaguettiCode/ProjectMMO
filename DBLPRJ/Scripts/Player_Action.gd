extends CharacterBody3D

@onready var navigationAgent : NavigationAgent3D = $NavigationAgent3D
@onready var cameraAgent : Camera3D = $"../Camera3D"

var error = ErrorCode
var Speed = 5


func moveCameraToPlayer():
	cameraAgent.position.x = self.position.x + 10
	cameraAgent.position.z = self.position.z



func _process(delta):
	if(navigationAgent.is_navigation_finished()):
		return 
	moveToPoint(delta, Speed)
	moveCameraToPlayer()
	pass

func moveToPoint(delta, speed):
	var targetPos = navigationAgent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	faceDirection(targetPos)
	velocity = direction * speed
	move_and_slide()

func faceDirection(direction):
	look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)

func _input(event):
	if Input.is_action_just_pressed("LeftMouse"):
		var camera = get_tree().get_nodes_in_group("Camera")[0]
		var mousePos = get_viewport().get_mouse_position()
		var rayLength = 100
		var from = camera.project_ray_origin(mousePos)
		var to = from + camera.project_ray_normal(mousePos) * rayLength
		var space = get_world_3d().direct_space_state
		var rayQuery = PhysicsRayQueryParameters3D.new()
		rayQuery.from = from
		rayQuery.to = to
		rayQuery.collide_with_areas = true
		rayQuery.collide_with_bodies = true
		
		var result = space.intersect_ray(rayQuery)
		if !result.is_empty():
			navigationAgent.target_position = result.position
		else:
			error.MessageError(1)
