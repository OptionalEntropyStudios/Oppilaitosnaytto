extends breakable

@onready var navAgent: NavigationAgent3D = $NavigationAgent3D
var moveTarget: Node3D
@export var cannon : Node3D
@export var cannon2: Node3D
@export var moveSpeed : float
@export var accelerationSpeed : float
var direction
@export var canMove : bool = false
func _physics_process(delta: float) -> void:
	if(canMove):
		direction = Vector3() #Cast the variable as a Vector3 to minimize errors later in function
		if(navAgent != null):
			navAgent.target_position = moveTarget.global_position #Set the navigationAgent's targetpos to be the target we want the moving thing to move toward
			var nextTargetPos = navAgent.get_next_path_position()
			#Get the Vector3 pointing toward next moveposition
			direction = nextTargetPos - global_position
			#Normalize the vector to remove weird movement glitches
			direction = direction.normalized()
			#look at direction of travel
			look_at(global_position + direction, Vector3.UP)
			#move toward the target at the speed specified
			velocity = velocity.lerp(direction * moveSpeed, accelerationSpeed * delta)
			move_and_slide()
