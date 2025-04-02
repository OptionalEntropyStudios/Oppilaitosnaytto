extends Node3D

@onready var shootRay: RayCast3D = $shootRay

@onready var pistol = $pistol
@onready var smg# = $smg
@onready var shotgun #= $smg

signal reloadButtonPressed
enum guns {PISTOL, SMG, SHOTGUN}
var equippedGunEnum : guns
var equippedGun : gun
var gunToEquip
func _ready() -> void:
	gunToEquip = guns.PISTOL
	equipGun(gunToEquip)
func _process(delta: float) -> void:
	getGunSelection()
	if(gunToEquip != equippedGunEnum):
		equipGun(gunToEquip)
	if(Input.is_action_pressed("shoot")):
		equippedGun.shoot(shootRay)
	if(Input.is_action_just_pressed("reload")):
		reloadButtonPressed.emit()
	updateEquippedGunAmmoCounter()

func equipGun(gun : guns):
	match gun:
		guns.PISTOL:
			pistol.equipped = true
			#smg.equipped = false
			#shotgun.equipped = false
			equippedGun = pistol
		guns.SMG:
			pistol.equipped = false
			#smg.equipped = true
			#shotgun.equipped = false
			#equippedGun = smg
		guns.SHOTGUN:
			pistol.equipped = false
			#smg.equipped = false
			#shotgun.equipped = true
			#equippedGun = shotgun
	equippedGunEnum = gunToEquip
	print("Equipped " + str(guns.keys()[equippedGunEnum]))

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
