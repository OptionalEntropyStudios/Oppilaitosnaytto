extends CharacterBody3D

@export var health : int = 100
@export var maxHealth : int = 100
var healthIndicatorAlpha : float = 0.0
var username : String
var setUsername : bool = false
@onready var weaponManager: Node3D = $playerCamera/weaponManager

@export var stopSpeed : float = 3 * 10
var currentSpeed : float
@export var walkingSpeed : float = 50
@export var runningSpeed : float = 70
@export var crouchingSpeed : float = 30
enum moveState {WALKING, RUNNING}
enum standState {STANDING, CROUCHING}

@onready var playerBody: CollisionShape3D = $playerBody
var standingHeight
var crouchingHeight
@export var jumpForce : float = 35.0
@export var gravityForce : float = 3.5
#DEBUGGING
@onready var moveStateLbl: Label = $playerUI/moveStateLable
var prevMoveState
@onready var standStateLbl: Label = $playerUI/standStateLabel
var prevStandState
@onready var groundedStateLbl: Label = $playerUI/groundedStateLabel
var prevGroundedState
#END OF DEBUGGING
func _ready() -> void:
	standingHeight = playerBody.scale.y
	crouchingHeight = standingHeight / 2
	username = loadLastLoggedInUser()
	weaponManager.playerName = username
	health = maxHealth
	healthCounter.text = str(health)
	#weaponManager.checkGunStatsAndOwnership()
func _physics_process(delta: float) -> void:
	gravity()
	checkJump()
	doMovementStuff(delta) #Handle all the movement logic in this function
	move_and_slide() #Built in script to handle the actual translation of the player body when input is applied
func _process(delta: float) -> void:
	if(is_on_floor() != prevGroundedState):
		groundedStateLbl.text = "GROUNDEDSTATE : " + str(is_on_floor())
		prevGroundedState = is_on_floor()
	if(Input.is_action_pressed("crouch")):
		playerBody.scale.y = crouchingHeight
	elif(playerBody.scale.y != standingHeight):
		playerBody.scale.y = standingHeight
	if(healthIndicatorAlpha > 0.0):
		healthIndicatorAlpha -= delta / 2
	hitColorIndicator.color = Color(1, 0, 0, healthIndicatorAlpha)
		
func checkStandState() -> standState:
	if(Input.is_action_pressed("crouch")):
		return standState.CROUCHING
	else: return standState.STANDING
func checkMoveState() -> moveState:
	if(Input.is_action_pressed("run") and !Input.is_action_pressed("crouch")):
		return moveState.RUNNING
	else: return moveState.WALKING
func checkMoveSpeed(movingState : moveState, standingState : standState) -> float:
	match standingState: ##First we check if the player is standing or not
		standState.CROUCHING: #If the player is crouching, they can't run so crouchspeed is they way to go
			return crouchingSpeed
		standState.STANDING: #If player is standing, 
			match movingState: #we check if they're walking or running
				moveState.WALKING:
					return walkingSpeed
				moveState.RUNNING:
					return runningSpeed
				_:
					return walkingSpeed
		_:
			return walkingSpeed
func doMovementStuff(delta : float):
	var movementInput = Vector2(Input.get_axis("strafeLeft", "strafeRight"), Input.get_axis("moveForward","moveBackward")) #get data from the movement axises
	var moveDirection = (transform.basis * Vector3(movementInput.x, 0, movementInput.y)).normalized() #create a movedirection vector from those
	var playerStandState = checkStandState() #check if the player is standing or crouching
	if(playerStandState != prevStandState):
		standStateLbl.text = "STANDSTATE : " + str(standState.keys()[playerStandState])
		prevStandState = playerStandState
	if(moveDirection): #if the vector has something, the player obviously wants to move
		var playerMoveState = checkMoveState() #check if player wants to run or walk
		currentSpeed = checkMoveSpeed(playerMoveState, playerStandState) #check and assign the movespeed according to the player state
		if(is_on_floor()): #Movement will only change when on the ground
			velocity.x = moveDirection.x * currentSpeed * delta * 10
			velocity.z = moveDirection.z * currentSpeed * delta * 10
		#THIS PART FOR DEBUGGING
		if(playerMoveState != prevMoveState):
			moveStateLbl.text = "MOVESTATE : " + str(moveState.keys()[playerMoveState])
			prevMoveState = playerMoveState
		#END FOR DEBUGGING
	else:
		velocity.x = move_toward(velocity.x, 0, stopSpeed) #If no input, move to a halt
		velocity.z = move_toward(velocity.z, 0, stopSpeed) #If no input, move to a halt
func gravity():
	if(!is_on_floor()):
		velocity.y -= gravityForce
func checkJump():
	if(Input.is_action_just_pressed("jump") and is_on_floor()):
		velocity.y += jumpForce

signal canLookNow
func tellCameraItIsOkToLook():
	canLookNow.emit()

func makeGunManagerCheckGunOwnerships():
	if(!username.is_empty()):
		username = loadLastLoggedInUser()
	await get_tree().create_timer(0.5).timeout
	weaponManager.checkOwnedGuns(username)

func loadLastLoggedInUser() -> String:
	var currentUserFile = FileAccess.open("user://currentUser.txt", FileAccess.READ)
	if(currentUserFile != null):
		var usrnm = currentUserFile.get_as_text()
		if(!usrnm.is_empty()):
			return usrnm
		else: return ""
	else: return ""

@onready var healthCounter: Label = $playerUI/healthTextContainer/healthIndicator
@onready var hitColorIndicator: ColorRect = $playerUI/hitIndicator

func takeDamage(damage : int):
	health -= damage
	healthIndicatorAlpha += 0.3
	healthCounter.text = str(health)
	if(health <= 0):
		die()

signal playerDied
func die():
	print("I fucking died :(")
	playerDied.emit()
	health = maxHealth
	healthCounter.text = str(health)
func getAmmo():
	weaponManager.addAmmoToGunReservers()
