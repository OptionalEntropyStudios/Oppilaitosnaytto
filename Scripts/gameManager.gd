extends Node3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #Capture the mouse, so it don't leave the screen

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("pause")): #If escape is pressed, quit game
		get_tree().quit()
