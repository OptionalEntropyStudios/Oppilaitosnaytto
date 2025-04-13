extends Control

@onready var loginButton: Button = $buttonContainer/loginButton
@onready var registerButton: Button = $buttonContainer/registerButton
@onready var usernameInput: LineEdit = $usernameLineEdit

@onready var userNotExistingLbl: Label = $userDoesNotExistlbl
@onready var userExistingLbl: Label = $userExistsAlready
@onready var userRegisteredLbl: Label = $userRegisteredSuccesfully
@onready var fieldEmptyLbl: Label = $fieldEmptyLbl


@onready var dbConnectionScript = load("res://Scripts/mySqlTestConneciton.cs")
var dbConnectionManager
var userFile : FileAccess
var username
func _ready() -> void:
	dbConnectionManager = dbConnectionScript.new()
	usernameInput.text = loadLastLoggedInUser()

func _process(delta: float) -> void:
	#If the notifications have been shown, fadce them away a little
	fadeNotificationsIfVisible(delta)
func onLoginButtonPressed():
	if(!usernameInput.text.is_empty()):
		username = usernameInput.text.to_lower()
		if(dbConnectionManager.UsernameExists(username)):
			setLoggedInUser(username)
			get_tree().change_scene_to_file("res://Scenes/3dGame.tscn")
		else:
			userNotExistingLbl.label_settings.font_color.a = 1
	else: fieldEmptyLbl.label_settings.font_color.a = 1
func onRegisterButtonPressed():
	if(!usernameInput.text.is_empty()):
		username = usernameInput.text.to_lower()
		if(!dbConnectionManager.UsernameExists(username)):
			dbConnectionManager.RegisterUser(username)
			userRegisteredLbl.label_settings.font_color.a = 1
		else: userExistingLbl.label_settings.font_color.a = 1
	else: fieldEmptyLbl.label_settings.font_color.a = 1

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

func fadeNotificationsIfVisible(delta):
	#They getting faded away at quarter speed in real time
	if(userNotExistingLbl.label_settings.font_color.a > 0):
		userNotExistingLbl.label_settings.font_color.a -= 0.25 * delta
	if(userExistingLbl.label_settings.font_color.a > 0):
		userExistingLbl.label_settings.font_color.a -= 0.25 * delta
	if(userRegisteredLbl.label_settings.font_color.a > 0):
		userRegisteredLbl.label_settings.font_color.a -= 0.25 * delta
	if(fieldEmptyLbl.label_settings.font_color.a > 0):
		fieldEmptyLbl.label_settings.font_color.a -= 0.25 * delta
