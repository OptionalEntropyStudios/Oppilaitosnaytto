extends Node3D

var mouseMovement
@export var swayLimit : float = 6
@export var swayLerpSpeed : float = 5

@export var swayLeft : Vector3
@export var swayRight : Vector3
@export var swayNormal : Vector3

func _input(event: InputEvent) -> void:
	if(event is InputEventMouseMotion):
		mouseMovement = -event.relative.x #If an input event is called, check if the event was mousemovement
							#and store the x-axis input if it was

func _process(delta: float) -> void:
	if(mouseMovement != null): #If there was mouse movement
		swayHorizontal(delta)
func swayHorizontal(delta):
	if(mouseMovement > swayLimit): #If the movement was larger than the limit needed to sway the gun
		rotation = rotation.lerp(swayLeft, swayLerpSpeed * delta) #Rotate the gun left at the specified speed
	elif(mouseMovement < -swayLimit):
		rotation = rotation.lerp(swayRight, swayLerpSpeed * delta) #Rotate it right
	else: rotation = rotation.lerp(swayNormal, swayLerpSpeed * delta) #If input is less than the limit, return to normal pos
