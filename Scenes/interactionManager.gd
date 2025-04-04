extends Node3D

@onready var interactRay: RayCast3D = $interactionRay

func _process(delta: float) -> void:
	if(interactRay.is_colliding()):
		var hitObject = interactRay.get_collider()
		if(hitObject.is_in_group("button")):
			if(Input.is_action_just_pressed("interact")):
				print("pressed button")
				hitObject.press()
