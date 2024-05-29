extends CharacterBody3D

var Speed : int = 20
var direction : Vector3 = Vector3.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	direction = direction.normalized()
	velocity.x = Speed * direction.x
	velocity.z = Speed * direction.z
	move_and_slide()
