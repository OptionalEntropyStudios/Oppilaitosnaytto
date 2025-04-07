extends Node3D

@onready var player: CharacterBody3D = $Player
var currentUser

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #Capture the mouse, so it don't leave the screen
	currentUser = loadLastLoggedInUser()
	player.username = currentUser
	await get_tree().create_timer(0.5).timeout
	player.tellCameraItIsOkToLook()
func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("pause")): #If escape is pressed, quit game
		get_tree().quit()

func loadLastLoggedInUser() -> String:
	var currentUserFile = FileAccess.open("user://currentUser.txt", FileAccess.READ)
	if(currentUserFile != null):
		var username = currentUserFile.get_as_text()
		if(!username.is_empty()):
			return username
		else: return ""
	else: return ""
