extends menu
var dbConnectionScript = preload("res://Scripts/mySqlTestConneciton.cs")
var dbConnectionManager
var username
@onready var buyHealthPackButton: button = $buyHealthPackButton
@export var store: Node3D
func _ready() -> void:
	dbConnectionManager = dbConnectionScript.new()
	await get_tree().create_timer(0.1).timeout
	username = store.username
	
@onready var healthPackTitle: Label3D = $healthPackOption/healthPackText

func getHealthPackPrice():
	var healthPackPrice = dbConnectionManager.getEquipmentPrice("health")
	healthPackTitle.text = "HEALTHPACK\n price: " + str(healthPackPrice)
func buyHealthPack():
	if(dbConnectionManager.canBuyEquipment(username, "health")):
		dbConnectionManager.BuyOneEquipment(username, "health")
		store.healthPackBought.emit()
		store.refreshCreditsAmount()
func disableAllButtons():
	buyHealthPackButton.enabled = false
	buyHealthPackButton.checkPressability()

func enableAllButtons():
	buyHealthPackButton.enabled = true
	buyHealthPackButton.checkPressability()
	getHealthPackPrice()
