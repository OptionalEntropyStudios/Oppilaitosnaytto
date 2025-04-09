extends Node3D
signal spawnRobot
func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("shoot")):
		spawnRobot.emit()
