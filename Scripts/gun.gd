extends Node3D
class_name gun

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

@export var bulletDamage : int = 5

@export var reloading : bool
@export var equipped : bool #Check if the gun is equipped or not
@export var fullAuto : bool #if full auto, holding mouse go pew pew
@export var triggerReset : bool = false
@export var fireRate : float = 0.5 #how fast gun shoot
@export var magazineSize : int #how muh ammo can be in one magazine
@export var ammoInMagazine : int #how many bullets left
@export var reserveAmmoAmount : int
@export var reloadTime : float

func _process(delta: float) -> void:
	visible = equipped
	if(Input.is_action_just_released("shoot")): #If the fire button is released
		triggerReset = true
func shoot(shootRay : RayCast3D):
	if(equipped and ammoInMagazine > 0 and !reloading):
		if(not fullAuto and triggerReset and !animationPlayer.is_playing()):
			triggerReset = false
			animationPlayer.play("shoot")
			ammoInMagazine -= 1
			if(shootRay.is_colliding() and shootRay.get_collider() != null):
				var hitObject = shootRay.get_collider()
				print(name + " hit " + hitObject.name)
				if(hitObject is breakable):
					hitObject.takeDamage(bulletDamage)
		elif(!animationPlayer.is_playing()):
			animationPlayer.play("shoot")
			ammoInMagazine -= 1
			if(shootRay.is_colliding() and shootRay.get_collider() != null):
				var hitObject = shootRay.get_collider()
				print(name + " hit " + hitObject.name)
				if(hitObject is breakable):
					hitObject.takeDamage(bulletDamage)
		print(name + " has fired a round, " + str(ammoInMagazine) + " left")
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
	print("reload function called")
	if(reserveAmmoAmount > 0 and ammoInMagazine < magazineSize):
		reloading = true
		animationPlayer.play("reload")

func onShootAnimationFinished():
	triggerReset = true
