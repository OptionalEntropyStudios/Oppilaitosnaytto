extends Node3D

var username
var userCredits : int

var dbConnectionManager
var ownedGuns : Array
@onready var player: CharacterBody3D = $"../../Player"
@onready var weaponManager: Node3D = $"../../Player/playerCamera/weaponManager"
@onready var gunHolder: Node3D = $"../../Player/playerCamera/weaponManager/gunHolder"

@onready var gunsMenu = $gunsMenu
@onready var equipmentMenu = $equipmentMenu

signal updateUserGunOwnership
signal storeReady
func _ready() -> void:
	username = loadLastLoggedInUser()
	$usernameLbl.text = "current user : " + username
	dbConnectionManager = get_tree().get_first_node_in_group("sql")
	refreshCreditsAmount()
	gunsMenu.weaponManager = weaponManager
	gunsMenu.gunHolder = gunHolder
	gunsMenu.hideAllBuyGunButtons()
	gunsMenu.hideAllGunMenus()
	gunsMenu.hideAllGunMenuButtons()
	gunsMenu.hideGunBuyMenuButton()
	gunsMenu.hideUpgradeButtons()
	equipmentMenu.username = username
	storeReady.emit()
func refreshCreditsAmount():
	userCredits = dbConnectionManager.getUserCredits(username)
	$creditsAmountLbl.text = "Credits: " + str(userCredits)

func selectGunsMenu():
	equipmentMenu.deSelect()
	gunsMenu.select()
	gunsMenu.showOwnedGunMenus()
	gunsMenu.hideAllBuyGunButtons()
	gunsMenu.hideAllGunMenus()
	gunsMenu.hideUpgradeButtons()
	equipmentMenu.disableAllButtons()
	if(!gunsMenu.pistolOwned or !gunsMenu.smgOwned or !gunsMenu.shotgun):
		gunsMenu.showGunBuyMenuButton()
func selectEquipmentMenu():
	equipmentMenu.select()
	gunsMenu.deSelect()
	gunsMenu.hideUpgradeButtons()
	gunsMenu.hideAllGunMenuButtons()
	gunsMenu.hideAllBuyGunButtons()
	gunsMenu.hideGunBuyMenuButton()
	equipmentMenu.enableAllButtons()
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

signal healthPackBought
