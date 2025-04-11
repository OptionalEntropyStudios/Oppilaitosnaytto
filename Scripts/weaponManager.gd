extends Node3D

@onready var shootRay: RayCast3D = $shootRay
@onready var camera: Camera3D = $".."
@onready var playerName : String
@onready var pistol = $gunHolder/pistol
@onready var smg = $gunHolder/smg
@onready var shotgun = $gunHolder/shotgun

var dbConnectionScript = preload("res://Scripts/mySqlTestConneciton.cs")
var dbConnectionManager
@onready var hand: Node3D = $gunHolder

signal reloadButtonPressed #to be used to signal reload in the the guns' scripts
enum guns {PISTOL, SMG, SHOTGUN} #available guns in the game
var equippedGunEnum : guns #Keeps track of the enumerator value for which gun is equipped
var equippedGun : gun
var gunToEquip

#tracking accuracy
var firedShots : int = 0
var missedShots : int = 0
var hitShots : int = 0
var accuracyPrcnt : float = 100.0
@onready var shotStatsLbl: Label = $"../../playerUI/firedShotsLbl"

@onready var shotGunRaysParent: Node3D = $shotGunRays


#DEBUG OVER HERE LOL
@onready var gunNameLbl: Label = $"../../playerUI/gunNameLabel"
@onready var gunDmgLbl: Label = $"../../playerUI/gunDamageLabel"
@onready var gunFullAutoLbl: Label = $"../../playerUI/gunFullAutoStatus"

#DEBUG OVER
func _ready() -> void:
	dbConnectionManager = dbConnectionScript.new()
	randomizePelletRays()
func _process(delta: float) -> void:
	if(equippedGun != null):
		if(!equippedGun.animationPlayer.is_playing()):
			getGunSelection()
			if(gunToEquip != equippedGunEnum):
				equipGun(gunToEquip)
		if(Input.is_action_pressed("shoot")):
			equippedGun.shoot(shootRay, shotGunRaysParent)
		if(Input.is_action_just_released("shoot")):
			equippedGun.onFireKeyUp()
		if(Input.is_action_just_pressed("reload")):
			reloadButtonPressed.emit()
		updateEquippedGunAmmoCounter()
	else:
		ammoCounter.visible = false


func equipGun(firearm : guns): #Check which gun the player wants to equip
	match firearm:
		guns.PISTOL:
			pistol.getEquipped()
			smg.getUnEquipped()
			shotgun.getUnEquipped()
			equippedGun = pistol
		guns.SMG:
			pistol.getUnEquipped()
			smg.getEquipped()
			shotgun.getUnEquipped()
			equippedGun = smg
		guns.SHOTGUN:
			pistol.getUnEquipped()
			smg.getUnEquipped()
			shotgun.getEquipped()
			equippedGun = shotgun
	equippedGunEnum = gunToEquip
	gunNameLbl.text = "EQUIPPED GUN = " + equippedGun.name
	gunDmgLbl.text = "GUN DAMAGE = " + str(equippedGun.bulletDamage)
	if(equippedGun.fullAuto):
		gunFullAutoLbl.text =  "GUN FIREMODE = FULL AUTO"
	else: gunFullAutoLbl.text = "GUN FIREMODE = SEMI AUTO"
func getGunSelection():
	if(Input.is_action_just_pressed("equipPistol") and pistol.owned):
		gunToEquip = guns.PISTOL
	if(Input.is_action_just_pressed("equipSMG") and smg.owned):
		gunToEquip = guns.SMG
	if(Input.is_action_just_pressed("equipShotgun") and shotgun.owned):
		gunToEquip = guns.SHOTGUN

@onready var ammoCounter: Label = $"../../playerUI/ammoTextContainer/ammoCounter"

func updateEquippedGunAmmoCounter():
	if(!ammoCounter.visible):
		ammoCounter.visible = true
	ammoCounter.text = str(equippedGun.ammoInMagazine) + " / " + str(equippedGun.reserveAmmoAmount)
func randomizePelletRays():
	var spread = shotgun.shotGunSpreadAmount
	for ray in shotGunRaysParent.get_children():
		ray.rotation_degrees.x = randf_range(-spread, spread)
		ray.rotation_degrees.y = randf_range(-spread, spread)

func checkGunStatsAndOwnership():
	if(!playerName.is_empty()):
		checkOwnedGuns(playerName)
func checkOwnedGuns(username : String):
	pistol.owned = dbConnectionManager.isOwned(username, pistol.name)
	smg.owned = dbConnectionManager.isOwned(username, smg.name)
	shotgun.owned = dbConnectionManager.isOwned(username, shotgun.name)
	if(shotgun.owned):
		gunToEquip = guns.SHOTGUN
	if(smg.owned):
		gunToEquip = guns.SMG
	if(pistol.owned):
		gunToEquip = guns.PISTOL
	if(gunToEquip != null):
		equipGun(gunToEquip)
	updateWeaponStats()
enum weaponUpgrades{BULLETDAMAGE = 1, FIRERATE = 2, MAGAZINESIZE = 3, RELOADSPEED = 4} #To minimize "magic numbers in the below function
##Function will update each owned gun's stats based on those in the database
func updateWeaponStats():
	##Update pistol's stats
	if(pistol.owned):
		pistol.bulletDamage = pistol.baseDamage + getWeaponStat(weaponUpgrades.BULLETDAMAGE, "pistol")
		pistol.firerate = pistol.baseFirerate + getWeaponStat(weaponUpgrades.FIRERATE, "pistol")
		pistol.magazineSize = pistol.baseMagazineSize + getWeaponStat(weaponUpgrades.MAGAZINESIZE, "pistol")
		pistol.reloadSpeed = pistol.baseReloadSpeed + getWeaponStat(weaponUpgrades.RELOADSPEED, "pistol")
		pistol.ammoInMagazine = pistol.magazineSize
		pistol.reserveAmmoAmount = pistol.magazineSize * 5
	#update smgs stats
	if(smg.owned):
		smg.bulletDamage = smg.baseDamage + getWeaponStat(weaponUpgrades.BULLETDAMAGE, "smg")
		smg.firerate = smg.baseFirerate + getWeaponStat(weaponUpgrades.FIRERATE, "smg")
		smg.magazineSize = smg.baseMagazineSize + getWeaponStat(weaponUpgrades.MAGAZINESIZE, "smg")
		smg.reloadSpeed = smg.baseReloadSpeed + getWeaponStat(weaponUpgrades.RELOADSPEED, "smg")
		smg.ammoInMagazine = smg.magazineSize
		smg.reserveAmmoAmount = smg.magazineSize * 5
	#update shotgun stats
	if(shotgun.owned):
		shotgun.bulletDamage = shotgun.baseDamage + getWeaponStat(weaponUpgrades.BULLETDAMAGE, "shotgun")
		shotgun.firerate = shotgun.baseFirerate + getWeaponStat(weaponUpgrades.FIRERATE, "shotgun")
		shotgun.magazineSize = shotgun.baseMagazineSize + getWeaponStat(weaponUpgrades.MAGAZINESIZE, "shotgun")
		shotgun.reloadSpeed = shotgun.baseReloadSpeed + getWeaponStat(weaponUpgrades.RELOADSPEED, "shotgun")
		shotgun.ammoInMagazine = shotgun.magazineSize
		shotgun.reserveAmmoAmount = shotgun.magazineSize * 5
	
##Calculates the actual value of the stat based on the level and which weapon it be
func getWeaponStat(stat : weaponUpgrades, weapon : String) -> float:
	#print("function getWeaponStat called for " + weapon + " and " + str(weaponUpgrades.keys()[stat - 1]))
	var damageMultiplier
	var firerateMultiplier
	var magazineSizeMultiplier
	var reloadSpeedMultiplier
	##Different guns have different multipliers for the levels
	if(weapon == "pistol"):
		damageMultiplier = 3 #Each level will add 3 to the damage of one bullet
		firerateMultiplier = 0.2 #Each level will make the firerate a fifth faster
		magazineSizeMultiplier = 2 #Each level will add 2 bullets to the maximum capacity
		reloadSpeedMultiplier = 0.33 #Each level will make the reload a 33% faster
	if(weapon == "smg"):
		damageMultiplier = 2
		firerateMultiplier = 0.25
		magazineSizeMultiplier = 10 
		reloadSpeedMultiplier = 0.33
	if(weapon == "shotgun"):
		damageMultiplier = 8
		firerateMultiplier = 0.1
		magazineSizeMultiplier = 1
		reloadSpeedMultiplier = 0.5
	var upgradeLvl = dbConnectionManager.GetWeaponUpgradeLvl(playerName, weapon, stat)
	match stat:
		weaponUpgrades.BULLETDAMAGE:
			return upgradeLvl * damageMultiplier
		weaponUpgrades.FIRERATE:
			return upgradeLvl * firerateMultiplier
		weaponUpgrades.MAGAZINESIZE:
			return upgradeLvl * magazineSizeMultiplier
		weaponUpgrades.RELOADSPEED:
			return upgradeLvl * reloadSpeedMultiplier
	return 0.0


func addAmmoToGunReservers():
	pistol.reserveAmmoAmount += pistol.magazineSize * 2
	smg.reserveAmmoAmount += smg.magazineSize * 2
	shotgun.reserveAmmoAmount += shotgun.magazineSize * 2
	updateEquippedGunAmmoCounter()

func onShotFired():
	firedShots += 1
	updateShotstatsLbl()

func onShotMissed():
	missedShots += 1
	updateShotstatsLbl()

func onShotHit():
	hitShots += 1
	updateShotstatsLbl()

func updateShotstatsLbl():
	countShotAccuracy()
	shotStatsLbl.text = "Total shots = " + str(firedShots) + "\n hit shots = " + str(hitShots) + "\n missed shots = " + str(missedShots) + "\n accuracy% = " + str(accuracyPrcnt)

func countShotAccuracy():
	var shotsFloat = float(firedShots)
	var hitShotsFloat = float(hitShots)
	if(firedShots > 0):
		var unRoundedAccuracyPrcnt = float(hitShotsFloat / shotsFloat) * 100
		accuracyPrcnt = snapped(unRoundedAccuracyPrcnt, 0.01)
