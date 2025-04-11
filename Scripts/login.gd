extends Control

@onready var loginButton: Button = $buttonContainer/loginButton
@onready var registerButton: Button = $buttonContainer/registerButton
@onready var usernameInput: LineEdit = $usernameLineEdit
@onready var dbConnectionScript = load("res://Scripts/mySqlTestConneciton.cs")
var dbConnectionManager
var userFile : FileAccess
var username
func _ready() -> void:
	dbConnectionManager = dbConnectionScript.new()
	usernameInput.text = loadLastLoggedInUser()

func onLoginButtonPressed():
	if(!usernameInput.text.is_empty()):
		username = usernameInput.text.to_lower()
		if(dbConnectionManager.UsernameExists(username)):
			setLoggedInUser(username)
			get_tree().change_scene_to_file("res://Scenes/3dGame.tscn")
		else:
			print("vitu paska")
	else: print("there is nothing in the text field")
func onRegisterButtonPressed():
	if(!usernameInput.text.is_empty()):
		username = usernameInput.text.to_lower()
		if(!dbConnectionManager.UsernameExists(username)):
			dbConnectionManager.RegisterUser(username)
			setLoggedInUser(username)
		else: print("the username is already taken lol")
	else: print("there is nothing in the text field")

func setLoggedInUser(loggedInUsername : String):
	var currentUserFile = FileAccess.open("user://currentUser.txt", FileAccess.WRITE)
	currentUserFile.store_string(loggedInUsername)


func loadLastLoggedInUser() -> String:
	var currentUserFile = FileAccess.open("user://currentUser.txt", FileAccess.READ)
	if(currentUserFile != null):
		username = currentUserFile.get_as_text()
		if(!username.is_empty()):
			return username
		else: return ""
	else: return ""

func quitGame():
	get_tree().quit()
