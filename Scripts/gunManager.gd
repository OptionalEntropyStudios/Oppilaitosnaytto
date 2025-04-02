extends XRController3D

var gunMenuOpened : bool = false
var globalPosWhenOpened
var rotationWhenSpawned
@export var gunMenu: Node3D
@onready var pistol: pistolV3 = $pistolV3

@onready var hand: XRToolsHand = $RightHand

signal triggerClicked
signal triggerReset
signal dropButtonPressed
var isDropButtonPressed : bool = false
var isTriggerPulled : bool = false
var smg = null
var shotgun = null
var isGunSelectedFromMenu : bool = false
var prevEquippedGunState
var equippedGun
enum equippableGuns {PISTOL, SMG, SHOTGUN, HAND = -1}
func _ready() -> void:
	isGunSelectedFromMenu = false
	prevEquippedGunState = equippedGun
	equippedStateMachine()
func _process(delta: float) -> void:
	if(get_input("by_button")): #If the b or y button is pressed on the Touch controllers
		if(!gunMenuOpened): #Check if the gun menu is opened
			globalPosWhenOpened = hand.global_position
			rotationWhenSpawned = rotation_degrees.y
			isGunSelectedFromMenu = false
			gunMenu.visible = true #Show the menu if it's not showed yet
			gunMenuOpened = gunMenu.visible #Set the earlier bool to true
		gunMenu.global_position = globalPosWhenOpened
		gunMenu.rotation_degrees.y = rotationWhenSpawned
	elif(!isGunSelectedFromMenu):
		isGunSelectedFromMenu = true
		equippedGun = gunMenu.selectedGun #Assign the gun we got from the menu to the one
		gunMenu.visible = false
		gunMenuOpened = gunMenu.visible
		
	if(equippedGun != prevEquippedGunState):
		equippedStateMachine()
	if(get_input("trigger_click")):
		if(!isTriggerPulled):
			isTriggerPulled = true
			triggerClicked.emit()
	triggerIsReset()
	if(get_input("ax_button") and !isDropButtonPressed):
		isDropButtonPressed = true
		dropButtonPressed.emit()
	if(!get_input("ax_button") and isDropButtonPressed):
		isDropButtonPressed = false
func equippedStateMachine(): #check which gun is enabled and hide all others
	match equippedGun:
		equippableGuns.PISTOL:
			print("pistol is equipped")
			pistol.visible = true
			hand.visible = false
			#smg.visible = false
			#shotgun.visible = false
		equippableGuns.SMG:
			print("smg is equipped")
			pistol.visible = false
			#smg.visible = true
			#shotgun.visible = false
			hand.visible = false
		equippableGuns.SHOTGUN:
			print("shotgun is equipped")
			pistol.visible = false
			#smg.visible = false
			#shotgun.visible = true
			hand.visible = false
		equippableGuns.HAND:
			print("hand is equipped")
			pistol.visible = false
			#smg.visible = false
			#shotgun.visible = false
			hand.visible = true
		_:
			equippedGun = equippableGuns.HAND
			print("hand is equipped")
			hand.visible = true
			pistol.visible = false
			#smg.visible = false
			#shotgun.visible = false
	prevEquippedGunState = equippedGun
	
func triggerIsReset():
	if(!get_input("trigger_click")):
		isTriggerPulled = false
		triggerReset.emit()
