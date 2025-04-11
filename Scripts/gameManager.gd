extends Node3D

@onready var player: CharacterBody3D = $Player
var currentUser
@onready var pauseMenu: ColorRect = $pauseMenu
@onready var playerUI: Control = $Player/playerUI

var showPauseMenu : bool = false
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #Capture the mouse, so it don't leave the screen
	currentUser = loadLastLoggedInUser()
	player.username = currentUser
	pauseMenu.hide()
	playerUI.show()
	await get_tree().create_timer(0.5).timeout
	player.tellCameraItIsOkToLook()
func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("pause")): #If escape is pressed, quit game
		toggleMenu()

func loadLastLoggedInUser() -> String:
	var currentUserFile = FileAccess.open("user://currentUser.txt", FileAccess.READ)
	if(currentUserFile != null):
		var username = currentUserFile.get_as_text()
		if(!username.is_empty()):
			return username
		else: return ""
	else: return ""

func pauseGame():
	get_tree().paused = true
	pauseMenu.show()
	playerUI.hide()
	showPauseMenu = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED) 

func continueGame():
	get_tree().paused = false
	showPauseMenu = false
	pauseMenu.hide()
	playerUI.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #Capture the mouse, so it don't leave the screen

func returnToLoginMenu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/userLogin.tscn")

func quitGame():
	get_tree().quit()
func toggleMenu():
	showPauseMenu = !showPauseMenu
	if(showPauseMenu):
		pauseGame()
	else: continueGame()
