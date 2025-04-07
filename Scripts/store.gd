extends Node3D

var username
var userCredits : int
var dbConnectionScript = preload("res://Scripts/mySqlTestConneciton.cs")
var dbConnectionManager
var ownedGuns : Array
@onready var player = $"../Player"
@onready var weaponManager: Node3D = $"../Player/playerCamera/weaponManager"
@onready var gunHolder: Node3D = $"../Player/playerCamera/weaponManager/gunHolder"

@onready var gunsMenu = $gunsMenu
@onready var equipmentMenu = $equipmentMenu

signal updateUserGunOwnership
signal storeReady
func _ready() -> void:
	username = loadLastLoggedInUser()
	$usernameLbl.text = "current user : " + username
	dbConnectionManager = dbConnectionScript.new()
	refreshCreditsAmount()
	gunsMenu.weaponManager = weaponManager
	gunsMenu.gunHolder = gunHolder
	storeReady.emit()
func refreshCreditsAmount():
	userCredits = dbConnectionManager.getUserCredits(username)
	$creditsAmountLbl.text = "Credits: " + str(userCredits)

func selectGunsMenu():
	equipmentMenu.deSelect()
	gunsMenu.select()

func selectEquipmentMenu():
	equipmentMenu.select()
	gunsMenu.deSelect()

func loadLastLoggedInUser() -> String:
	var currentUserFile = FileAccess.open("user://currentUser.txt", FileAccess.READ)
	if(currentUserFile != null):
		username = currentUserFile.get_as_text()
		if(!username.is_empty()):
			return username
		else: 
			return ""
	else: 
		return ""

func onGunBought():
	updateUserGunOwnership.emit() #Start the chain reaction that will end in player.weaponManager.CheckWeaponownership 
