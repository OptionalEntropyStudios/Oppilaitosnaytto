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
@onready var buyPistolButton: button = $buyMenu/buyPistolButton
@onready var buySmgButton: button = $buyMenu/buySmgButton
@onready var buyShotgunButton: button = $buyMenu/buyShotgunButton

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
	getGunPrices()
	updateGunOwnerShip.emit()

func openPistolMenu():
	weaponToApplyUpgradeTo = "pistol"
	pistolMenu.visible = true
	smgMenu.visible = false
	shotgunMenu.visible = false
	gunBuyMenu.visible = false
	hideAllBuyGunButtons()
	updatePistolStatLabels()
	showUpgradeButtons()

func openSmgMenu():
	weaponToApplyUpgradeTo = "smg"
	pistolMenu.visible = false
	smgMenu.visible = true
	shotgunMenu.visible = false
	gunBuyMenu.visible = false
	hideAllBuyGunButtons()
	updateSmgStatLabels()
	showUpgradeButtons()

func openShotgunMenu():
	weaponToApplyUpgradeTo = "shotgun"
	pistolMenu.visible = false
	smgMenu.visible = false
	shotgunMenu.visible = true
	gunBuyMenu.visible = false
	hideAllBuyGunButtons()
	updateShotgunStatLabels()
	showUpgradeButtons()

func showOwnedGunMenus():
	if(pistolOwned):
		showPistolMenuButton()
	if(smgOwned):
		showSmgMenuButton()
	if(shotgunOwned):
		showShotgunMenuButton()
@onready var pistolPriceLbl: Label3D = $buyMenu/buyPistolButton/buyPistol/priceLbl
@onready var smgPriceLbl: Label3D = $buyMenu/buySmgButton/buySmg/priceLbl
@onready var shotgunPriceLbl: Label3D = $buyMenu/buyShotgunButton/buyShotgun/priceLbl

func openGunBuyMenu():
	gunBuyMenu.visible = true
	pistolMenu.visible = false
	smgMenu.visible = false
	shotgunMenu.visible = false
	if(!pistolOwned):
		showBuyPistolButton()
	if(!smgOwned):
		showBuySmgButton()
	if(!shotgunOwned):
		showBuyShotgunButton()
	hideUpgradeButtons()
	getGunPrices() #used to refresh the buy buttons

func buyPistol():
	if(dbConnectionManager.CanBuyGun(username, "pistol")):
		dbConnectionManager.BuyGun(username, "pistol")
		getOwnedGuns() #used to refresh the buy buttons
		showOwnedGunMenus()
		hideBuyPistolButton()
		store.refreshCreditsAmount()



func buySmg():
	if(dbConnectionManager.CanBuyGun(username, "smg")):
		dbConnectionManager.BuyGun(username, "smg")
		getOwnedGuns()
		showOwnedGunMenus()
		hideBuySmgButton()
		store.refreshCreditsAmount()



func buyShotgun():
	if(dbConnectionManager.CanBuyGun(username, "shotgun")):
		dbConnectionManager.BuyGun(username, "shotgun")
		getOwnedGuns() #used to refresh the buy buttons
		showOwnedGunMenus()
		hideBuyShotgunButton()
		store.refreshCreditsAmount()


func getGunPrices():
	pistolPriceLbl.text = "COST : " + str(dbConnectionManager.GetWeaponPrice("pistol"))
	smgPriceLbl.text = "COST : " + str(dbConnectionManager.GetWeaponPrice("smg"))
	shotgunPriceLbl.text = "COST : " + str(dbConnectionManager.GetWeaponPrice("shotgun"))

@onready var damageUpBtn: button = $upgradeButtons/damageUpgrade
@onready var capacityUpBtn: button = $upgradeButtons/capacityUpgrade
@onready var firerateUpBtn: button = $upgradeButtons/firerateUpgrade
@onready var reloadUpBtn: button = $upgradeButtons/reloadUpgrade

func showUpgradeButtons():
	damageUpBtn.enabled = true
	damageUpBtn.checkPressability()
	capacityUpBtn.enabled= true
	capacityUpBtn.checkPressability()
	firerateUpBtn.enabled= true
	firerateUpBtn.checkPressability()
	reloadUpBtn.enabled= true
	reloadUpBtn.checkPressability()
func hideUpgradeButtons():
	damageUpBtn.enabled = false
	damageUpBtn.checkPressability()
	capacityUpBtn.enabled= false
	capacityUpBtn.checkPressability()
	firerateUpBtn.enabled= false
	firerateUpBtn.checkPressability()
	reloadUpBtn.enabled= false
	reloadUpBtn.checkPressability()
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

func hideGunBuyMenuButton():
	gunBuyMenuButton.enabled = false
	gunBuyMenuButton.checkPressability()
func showGunBuyMenuButton():
	gunBuyMenuButton.enabled = true
	gunBuyMenuButton.checkPressability()
func hideAllGunMenus():
	pistolMenu.visible = false
	smgMenu.visible = false
	shotgunMenu.visible = false
func hideAllGunMenuButtons():
	hidePistolMenuButton()
	hideSmgMenuButton()
	hideShotgunMenuButton()

func hideAllBuyGunButtons():
	hideBuyPistolButton()
	hideBuySmgButton()
	hideBuyShotgunButton()

func hidePistolMenuButton():
	pistolMenuButton.enabled = false
	pistolMenuButton.checkPressability()
func showPistolMenuButton():
	pistolMenuButton.enabled = true
	pistolMenuButton.checkPressability()
func hideSmgMenuButton():
	smgMenuButton.enabled = false
	smgMenuButton.checkPressability()
func showSmgMenuButton():
	smgMenuButton.enabled = true
	smgMenuButton.checkPressability()
func hideShotgunMenuButton():
	shotgunMenuButton.enabled = false
	shotgunMenuButton.checkPressability()
func showShotgunMenuButton():
	shotgunMenuButton.enabled = true
	shotgunMenuButton.checkPressability()
func showBuyPistolButton():
	buyPistolButton.enabled = true
	buyPistolButton.checkPressability()
func hideBuyPistolButton():
	buyPistolButton.enabled = false
	buyPistolButton.checkPressability()
func showBuySmgButton():
	buySmgButton.enabled = true
	buySmgButton.checkPressability()
func hideBuySmgButton():
	buySmgButton.enabled = false
	buySmgButton.checkPressability()
func showBuyShotgunButton():
	buyShotgunButton.enabled = true
	buyShotgunButton.checkPressability()
func hideBuyShotgunButton():
	buyShotgunButton.enabled = false
	buyShotgunButton.checkPressability()
