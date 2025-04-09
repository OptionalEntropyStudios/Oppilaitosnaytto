extends RigidBody3D

var fired : bool = false

@export var damageAmount : int = 5
@export var speed : float = 1

var lifetimeLimit : float = 10
var lifetime : float = 0


func _physics_process(delta: float) -> void:
	if(fired):
		apply_force(-transform.basis.z * speed, transform.basis.z)
		lifetime += delta
		if(lifetime > lifetimeLimit):
			queue_free()


func bulletHitSomething(body: Node3D) -> void:
	if(body.is_in_group("player")):
		body.takeDamage(damageAmount)
	queue_free()
