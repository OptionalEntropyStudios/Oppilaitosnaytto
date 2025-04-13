extends menu

var dbConnectionManager
var username
@onready var buyHealthPackButton: button = $buyHealthPackButton
@export var store: Node3D
func _ready() -> void:
	await get_tree().create_timer(0.3)
	dbConnectionManager = get_tree().get_first_node_in_group("sql")

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
