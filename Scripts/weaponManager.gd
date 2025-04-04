extends Node3D

@onready var shootRay: RayCast3D = $shootRay
@onready var camera: Camera3D = $".."
@onready var pistol = $gunHolder/pistol
@onready var smg = $gunHolder/smg
@onready var shotgun = $gunHolder/shotgun

@onready var hand: Node3D = $gunHolder

signal reloadButtonPressed
enum guns {PISTOL, SMG, SHOTGUN}
var equippedGunEnum : guns
var equippedGun : gun
var gunToEquip

@onready var shotGunRaysParent: Node3D = $shotGunRays


#DEBUG OVER HERE LOL
@onready var gunNameLbl: Label = $"../../playerUI/gunNameLabel"
@onready var gunDmgLbl: Label = $"../../playerUI/gunDamageLabel"
@onready var gunFullAutoLbl: Label = $"../../playerUI/gunFullAutoStatus"

#DEBUG OVER
func _ready() -> void:
	gunToEquip = guns.PISTOL
	equipGun(gunToEquip)
	randomizePelletRays()
func _process(delta: float) -> void:
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

func equipGun(gun : guns):
	match gun:
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
	if(Input.is_action_just_pressed("equipPistol")):
		gunToEquip = guns.PISTOL
		print("Player wants to equip " + guns.keys()[gunToEquip])
	if(Input.is_action_just_pressed("equipSMG")):
		gunToEquip = guns.SMG
		print("Player wants to equip " + guns.keys()[gunToEquip])
	if(Input.is_action_just_pressed("equipShotgun")):
		gunToEquip = guns.SHOTGUN
		print("Player wants to equip " + guns.keys()[gunToEquip])

@onready var ammoCounter: Label = $"../../playerUI/ammoTextContainer/ammoCounter"

func updateEquippedGunAmmoCounter():
	ammoCounter.text = str(equippedGun.ammoInMagazine) + " / " + str(equippedGun.reserveAmmoAmount)
@export var swayStrength : float
@export var swayLimit : float = 3.5

func randomizePelletRays():
	var spread = shotgun.shotGunSpreadAmount
	for ray in shotGunRaysParent.get_children():
		ray.rotation_degrees.x = randf_range(-spread, spread)
		ray.rotation_degrees.y = randf_range(-spread, spread)
