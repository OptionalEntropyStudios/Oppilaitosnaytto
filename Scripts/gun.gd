extends Node3D
class_name gun
var owned : bool = false
@onready var bulletHitDecal = preload("res://Scenes/hitHole.tscn")
@onready var hitDamageIndicator = preload("res://Scenes/baseScenes/damageIndicator.tscn")
@export var camera : Camera3D
@export var body: CharacterBody3D
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@export var muzzleEffect : MeshInstance3D

@export var reloading : bool
@export var usesMagazines : bool
@export var equipped : bool #Check if the gun is equipped or not
@export var fullAuto : bool #if full auto, holding mouse go pew pew
@export var triggerReset : bool = true
@export var cycleFinished : bool = true


@export var ammoInMagazine : int #how many bullets left
@export var reserveAmmoAmount : int

@export var baseDamage : int
@export var baseFirerate : float
@export var baseMagazineSize : int
@export var baseReloadSpeed : float
##UPGRADABLE STATS
@export var bulletDamage : int = 5 #upgradeID in database = 1
@export var firerate : float = 1 #upgradeID in database = 2
@export var magazineSize : int #upgradeID in database = 3 - how muh ammo can be in one magazine
@export var reloadSpeed : float = 1 #upgradeID in database = 4
##END OF UPGRADABLE STATS

@export var recoilAmount : float

@export var isShotgun : bool
@export var shotGunSpreadAmount : float = 10
signal oneAmmoLoaded

func shoot(shootRay : RayCast3D, shotgunRayParent : Node3D):
	if(equipped and !reloading):
		if(!ammoInMagazine > 0):
			reload()
		else:
			if(not fullAuto and triggerReset and !animationPlayer.is_playing()):
				applyRecoil()
				triggerReset = false
				muzzleEffect.rotation.z = randf_range(0, 180)
				muzzleEffect.show()
				animationPlayer.play("shoot", -1, firerate)
				ammoInMagazine -= 1
				await get_tree().create_timer(0.01).timeout
				muzzleEffect.hide()
				if(!isShotgun):
					if(shootRay.is_colliding() and shootRay.get_collider() != null):
						var hitObject = shootRay.get_collider()
						addHitHole(hitObject, shootRay.get_collision_point(), shootRay.get_collision_normal())
						if(hitObject is breakable):
							hitObject.takeDamage(bulletDamage)
							var damageIndicator = hitDamageIndicator.instantiate()
							get_tree().root.add_child(damageIndicator)
							damageIndicator.global_position = shootRay.get_collision_point()
							damageIndicator.damageText.text = "-" + str(bulletDamage)
							#damageIndicator.look_at(self.global_position, Vector3.UP)
				else:
					for pelletRay in shotgunRayParent.get_children():
						pelletRay.rotation_degrees.x = randf_range(-shotGunSpreadAmount,shotGunSpreadAmount)
						pelletRay.rotation_degrees.y = randf_range(-shotGunSpreadAmount,shotGunSpreadAmount)
						if(pelletRay.is_colliding() and pelletRay.get_collider() != null):
							var hitObject = pelletRay.get_collider()
							addHitHole(hitObject, pelletRay.get_collision_point(), pelletRay.get_collision_normal())
							if(hitObject is breakable):
								hitObject.takeDamage(bulletDamage)
								var damageIndicator = hitDamageIndicator.instantiate()
								get_tree().root.add_child(damageIndicator)
								damageIndicator.global_position = pelletRay.get_collision_point()
								damageIndicator.damageText.text = "-" + str(bulletDamage)
								#damageIndicator.look_at(self.global_position, Vector3.UP)
			elif(fullAuto and cycleFinished and !animationPlayer.is_playing()):
				applyRecoil()
				muzzleEffect.rotation.z = randf_range(0, 180)
				muzzleEffect.show()
				animationPlayer.play("shoot", -1, firerate)
				ammoInMagazine -= 1
				await get_tree().create_timer(0.01).timeout
				muzzleEffect.hide()
				if(shootRay.is_colliding() and shootRay.get_collider() != null):
					var hitObject = shootRay.get_collider()
					addHitHole(hitObject, shootRay.get_collision_point(), shootRay.get_collision_normal())
					if(hitObject is breakable):
						hitObject.takeDamage(bulletDamage)
						var damageIndicator = hitDamageIndicator.instantiate()
						get_tree().root.add_child(damageIndicator)
						damageIndicator.global_position = shootRay.get_collision_point()
						damageIndicator.damageText.text = "-" + str(bulletDamage)
						#damageIndicator.look_at(self.global_position, Vector3.UP)

func onReloadAnimationFinished(): #Called when the reload animation is done
	var bulletsMissingFromMagazine = magazineSize - ammoInMagazine #check how many bullets are missing from the mag
	if(reserveAmmoAmount >= bulletsMissingFromMagazine): #if there are more bullets in reserve than the missing amt
		ammoInMagazine += bulletsMissingFromMagazine #add the missing amt to the mag 
		reserveAmmoAmount -= bulletsMissingFromMagazine #substract added amount from reserve
	else:
		ammoInMagazine += reserveAmmoAmount
		reserveAmmoAmount = 0
	reloading = false
func reload():
	if(usesMagazines): #If the gun is like a pistol with a magazine
		if(reserveAmmoAmount > 0 and ammoInMagazine < magazineSize):
			reloading = true
			animationPlayer.play("reload", -1, reloadSpeed)
	else: #If the gun has individual shells or bullets being used, like sniper os shotgun
		if(reserveAmmoAmount > 0 and ammoInMagazine < magazineSize):
			reloading = true
			animationPlayer.play("reloadStart")

func onReloadStartAnimationFinished(): #When the start animation for the reload has finished
	if(ammoInMagazine < magazineSize and reserveAmmoAmount > 0 and !Input.is_action_pressed("shoot")): #check if the gun needs reloading or not
		keepReloading() #Play the single shot reload animation
	else: #If no more reload needed, go on and finish the reload animation
		animationPlayer.play("reloadFinish")

func singleReloadFinished():
	ammoInMagazine += 1
	reserveAmmoAmount -= 1
	oneAmmoLoaded.emit()
	onReloadStartAnimationFinished()
func keepReloading():
	animationPlayer.play("singleReload")
func onShootAnimationFinished():
	cycleFinished = true

func getEquipped():
	visible = true
	animationPlayer.play("equip")

func getUnEquipped():
	if(!animationPlayer.is_playing()):
		visible = false
		equipped = false
func onEquipAnimationFinished():
	equipped = true

func onFireKeyUp():
	triggerReset = true

func applyRecoil():
	var x_recoil = randf_range(0.1, recoilAmount)
	var y_recoil = randf_range(-recoilAmount, recoilAmount)
	camera.rotation_degrees.x += x_recoil
	body.rotation_degrees.y += y_recoil

func addHitHole(objectThatWasHit : Node3D, hitPoint : Vector3, hitPointNormal : Vector3): #Add hithole onto the spot that the bullet or pellet has hit
	var pointingUp = Vector3.UP
	var pointingDown = Vector3.DOWN
	var hitHole = bulletHitDecal.instantiate()
	objectThatWasHit.add_child(hitHole)
	hitHole.global_transform.origin = hitPoint
	if(hitPoint == pointingUp or hitPoint == pointingDown): #If the collided surface's normal is pointing up or down, change the lookat vector to the right so decal points straight up/down
		hitHole.look_at(hitPoint + hitPointNormal, Vector3.RIGHT)
	else:
		hitHole.look_at(hitPoint + hitPointNormal, Vector3.UP)
