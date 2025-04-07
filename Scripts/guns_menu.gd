extends menu


var dbConnectionScript = preload("res://Scripts/mySqlTestConneciton.cs")
var dbConnectionManager

var pistolOwned : bool = false
var smgOwned : bool = false
var shotgunOwned : bool = false

var weaponToApplyUpgradeTo #The weapon that will be getting the bought upgrade

@onready var pistolMenu: Node3D = $pistolMenu
@onready var smgMenu: Node3D = $smgMenu
@onready var shotgunMenu: Node3D = $shotgunMenu

@onready var pistolMenuButton: button = $pistolMenuButton
@onready var smgMenuButton: button = $smgMenuButton
@onready var shotgunMenuButton: button = $shotgunmenuButton

@onready var store: Node3D = $".."
@onready var gunHolder: Node3D
var weaponManager
var pistol # object to store the actual gun in, to get the variables like base damage etc.
var smg
var shotgun
@onready var gunBuyMenuButton: button = $gunBuyMenuButton
@onready var gunBuyMenu: Node3D = $buyMenu
@onready var buyPistolButton: Node3D = $buyMenu/buyPistol
@onready var buySmgButton: Node3D = $buyMenu/buySmg
@onready var buyShotgunButton: Node3D = $buyMenu/buyShotgun

var username
func storeDone() -> void:
	dbConnectionManager = dbConnectionScript.new()
	username = store.loadLastLoggedInUser()
	getOwnedGuns()
	if(gunHolder != null):
		smg = gunHolder.get_child(0)
		pistol = gunHolder.get_child(1)
		shotgun = gunHolder.get_child(2)
signal updateGunOwnerShip
func getOwnedGuns():
	#Check which guns are owned by the player
	pistolOwned = dbConnectionManager.isOwned(username, "pistol")
	smgOwned = dbConnectionManager.isOwned(username, "smg")
	shotgunOwned = dbConnectionManager.isOwned(username, "shotgun")
	#set buttons visible based on ownership
	pistolMenuButton.visible = pistolOwned
	smgMenuButton.visible = smgOwned
	shotgunMenuButton.visible = shotgunOwned
	getGunPrices()
	if(!pistolOwned or !smgOwned or !shotgunOwned): #If any of the guns is not owned, the buy menu will be visible
		gunBuyMenuButton.visible = true
		gunBuyMenu.visible = false
	else:
		gunBuyMenuButton.visible = false
	if(pistolOwned):
		buyPistolButton.visible = false
		if(!dbConnectionManager.HasUpgrades(username, "pistol")):
			dbConnectionManager.AddBaseUpgrades(username, "pistol")
	else:
		buyPistolButton.visible = true
	if(smgOwned):
		buySmgButton.visible = false
		if(!dbConnectionManager.HasUpgrades(username, "smg")):
			dbConnectionManager.AddBaseUpgrades(username, "smg")
	else:
		buySmgButton.visible = true
	if(shotgunOwned):
		buyShotgunButton.visible = false
		if(!dbConnectionManager.HasUpgrades(username, "shotgun")):
			dbConnectionManager.AddBaseUpgrades(username, "shotgun")
	else:
		buyShotgunButton.visible = true
	updateGunOwnerShip.emit()

func openPistolMenu():
	weaponToApplyUpgradeTo = "pistol"
	pistolMenu.visible = true
	smgMenu.visible = false
	shotgunMenu.visible = false
	gunBuyMenu.visible = false
	updatePistolStatLabels()

func openSmgMenu():
	weaponToApplyUpgradeTo = "smg"
	pistolMenu.visible = false
	smgMenu.visible = true
	shotgunMenu.visible = false
	gunBuyMenu.visible = false
	updateSmgStatLabels()

func openShotgunMenu():
	weaponToApplyUpgradeTo = "shotgun"
	pistolMenu.visible = false
	smgMenu.visible = false
	shotgunMenu.visible = true
	gunBuyMenu.visible = false
	updateShotgunStatLabels()

@onready var pistolPriceLbl: Label3D = $buyMenu/buyPistol/priceLbl
@onready var smgPriceLbl: Label3D = $buyMenu/buySmg/priceLbl
@onready var shotgunPriceLbl: Label3D = $buyMenu/buyShotgun/priceLbl

func openGunBuyMenu():
	gunBuyMenu.visible = true
	pistolMenu.visible = false
	smgMenu.visible = false
	shotgunMenu.visible = false
	getGunPrices() #used to refresh the buy buttons

func buyPistol():
	if(dbConnectionManager.CanBuyGun(username, "pistol")):
		dbConnectionManager.BuyGun(username, "pistol")
		getOwnedGuns() #used to refresh the buy buttons
		store.refreshCreditsAmount()



func buySmg():
	if(dbConnectionManager.CanBuyGun(username, "smg")):
		dbConnectionManager.BuyGun(username, "smg")
		getOwnedGuns()
		store.refreshCreditsAmount()



func buyShotgun():
	if(dbConnectionManager.CanBuyGun(username, "shotgun")):
		dbConnectionManager.BuyGun(username, "shotgun")
		getOwnedGuns() #used to refresh the buy buttons
		store.refreshCreditsAmount()


func getGunPrices():
	pistolPriceLbl.text = "COST : " + str(dbConnectionManager.GetWeaponPrice("pistol"))
	smgPriceLbl.text = "COST : " + str(dbConnectionManager.GetWeaponPrice("smg"))
	shotgunPriceLbl.text = "COST : " + str(dbConnectionManager.GetWeaponPrice("shotgun"))


func buyDamageUpgrade():
	if(dbConnectionManager.CanBuyUpgrade(username, weaponToApplyUpgradeTo, 1)):
		print("The user would like to buy the damage upgrade for " + weaponToApplyUpgradeTo)
		dbConnectionManager.BuyUpgrade(username, weaponToApplyUpgradeTo, 1)
		store.refreshCreditsAmount()
		updateStatsAfterUpgradePurchase()

func buyFirerateUpgrade():
	if(dbConnectionManager.CanBuyUpgrade(username, weaponToApplyUpgradeTo, 2)):
		print("The user would like to buy the firerate upgrade for " + weaponToApplyUpgradeTo)
		dbConnectionManager.BuyUpgrade(username, weaponToApplyUpgradeTo, 2)
		store.refreshCreditsAmount()
		updateStatsAfterUpgradePurchase()

func buyMagazineCapacityUpgrade():
	if(dbConnectionManager.CanBuyUpgrade(username, weaponToApplyUpgradeTo, 3)):
		print("The user would like to buy the magazine capacity upgrade for " + weaponToApplyUpgradeTo)
		dbConnectionManager.BuyUpgrade(username, weaponToApplyUpgradeTo, 3)
		store.refreshCreditsAmount()
		updateStatsAfterUpgradePurchase()

func buyReloadSpeedUpgrade():
	if(dbConnectionManager.CanBuyUpgrade(username, weaponToApplyUpgradeTo, 4)):
		print("The user would like to buy the reloadspeed upgrade for " + weaponToApplyUpgradeTo)
		dbConnectionManager.BuyUpgrade(username, weaponToApplyUpgradeTo, 4)
		store.refreshCreditsAmount()
		updateStatsAfterUpgradePurchase()


#the labels for pistol stats
@onready var pistolDamageLbl: Label3D = $pistolMenu/damageLbl
@onready var pistolFirerateLbl: Label3D = $pistolMenu/firerateLbl
@onready var pistolMagazineSizeLbl: Label3D = $pistolMenu/magazinesizeLbl
@onready var pistolReloadSpeedLbl: Label3D = $pistolMenu/reloadSpeedLbl
#the labels for smg stats
@onready var smgDamageLbl: Label3D = $smgMenu/damageLbl
@onready var smgFirerateLbl: Label3D = $smgMenu/firerateLbl
@onready var smgMagazineSizeLbl: Label3D = $smgMenu/magazinesizeLbl
@onready var smgReloadSpeedLbl: Label3D = $smgMenu/reloadSpeedLbl
#the labels for shotgun stats
@onready var shotgunDamageLbl: Label3D = $shotgunMenu/damageLbl
@onready var shotgunFirerateLbl: Label3D = $shotgunMenu/firerateLbl
@onready var shotgunMagazineSizeLbl: Label3D = $shotgunMenu/magazinesizeLbl
@onready var shotgunReloadSpeedLbl: Label3D = $shotgunMenu/reloadSpeedLbl

func updateStatsAfterUpgradePurchase():
	if(weaponToApplyUpgradeTo == "pistol"):
		updatePistolStatLabels()
	elif(weaponToApplyUpgradeTo == "smg"):
		updateSmgStatLabels()
	else:
		updateShotgunStatLabels()
	weaponManager.updateWeaponStats()
func updatePistolStatLabels():
	pistolDamageLbl.text = "damage\n" + str(pistol.baseDamage + weaponManager.getWeaponStat(1, "pistol"))
	pistolFirerateLbl.text = "firerate\n" +str(pistol.baseFirerate + weaponManager.getWeaponStat(2, "pistol"))
	pistolMagazineSizeLbl.text = "capacity\n" +str(pistol.baseMagazineSize + weaponManager.getWeaponStat(3, "pistol"))
	pistolReloadSpeedLbl.text = "reload speed\n" +str(pistol.baseReloadSpeed + weaponManager.getWeaponStat(4, "pistol"))
func updateSmgStatLabels():
	smgDamageLbl.text = "damage\n" +str(smg.baseDamage  + weaponManager.getWeaponStat(1, "smg"))
	smgFirerateLbl.text = "firerate\n" +str(smg.baseFirerate  + weaponManager.getWeaponStat(2, "smg"))
	smgMagazineSizeLbl.text = "capacity\n" +str(smg.baseMagazineSize  + weaponManager.getWeaponStat(3, "smg"))
	smgReloadSpeedLbl.text = "reload speed\n" +str(smg.baseReloadSpeed  + weaponManager.getWeaponStat(4, "smg"))
func updateShotgunStatLabels():
	shotgunDamageLbl.text = "damage\n" +str(shotgun.baseDamage  + weaponManager.getWeaponStat(1, "shotgun"))
	shotgunFirerateLbl.text = "firerate\n" +str(shotgun.baseFirerate  + weaponManager.getWeaponStat(2, "shotgun"))
	shotgunMagazineSizeLbl.text = "capacity\n" +str(shotgun.baseMagazineSize  + weaponManager.getWeaponStat(3, "shotgun"))
	shotgunReloadSpeedLbl.text = "reload speed\n" +str(shotgun.baseReloadSpeed  + weaponManager.getWeaponStat(4, "shotgun"))
