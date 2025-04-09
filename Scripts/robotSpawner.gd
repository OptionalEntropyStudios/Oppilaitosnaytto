extends Node3D

#for testing, will be removed
signal giveAmmo
####



@onready var robot = preload("res://Scenes/robot1_breakable.tscn")

var spawnPositions
@export var moveTarget : Node3D
@export var player : Node3D
@export var playerCharacter : CharacterBody3D
@export var basePosition : Node3D
@export var defencePosition : Node3D
var needToSpawnRobots : bool = false
var timeSinceLastRobotSpawned : float

@export var robotSpawnInterval : float = 2

#for data reasons
var robotsDestroyedDuringRun : int = 0 # how many robots the pa
var wavesElapsed : int = 0
var robotsPerWave : int = 5
var robotsSpawnedThisWave : int = 0
var robotsDestroyedThisWave : int = 0
var earnedCredits : int = 0
var creditAwardAmount : int = 1
var creditAwardAmountModifier : int = 1
##THE STATS FOR THE ROBOTS TO BE INCREASED EVERY WAVE
var robotHealth
@export var robotStartHealth : int = 10
var robotHealthWaveModifier : int = 5 #how much health the robots get every wave
var robotSpeed
@export var robotStartSpeed : float = 3.0
var robotSpeedWaveModifier : float = .1

var wavesSinceLastIncreasedCreditAwardAmount : int = 0
var creditAwardIncreaseInterval : int = 2
var playerName
var dbConnectionScript = preload("res://Scripts/mySqlTestConneciton.cs")
var dbConnectionManager
func _ready() -> void:
	timeSinceLastRobotSpawned = 0.0
	await get_tree().create_timer(0.5).timeout
	playerName = playerCharacter.username
	dbConnectionManager = dbConnectionScript.new()
func _process(delta: float) -> void:
	if(needToSpawnRobots):
		if(timeSinceLastRobotSpawned > robotSpawnInterval):
			timeSinceLastRobotSpawned = 0.0
			if(robotsSpawnedThisWave < robotsPerWave):
				print(str(robotsSpawnedThisWave) + " robots spawned, need to spawn " + str(robotsPerWave))
				spawnRobot()
			else:
				if(robotsDestroyedThisWave >= robotsSpawnedThisWave):
					robotsSpawnedThisWave = 0
					print("the " + str(wavesElapsed) + ". wave has been finished")
					wavesElapsed += 1
					elevateRobotStats()
		else:
			timeSinceLastRobotSpawned += delta

func spawnRobot():
	#Get one of the specified spawn positions
	var spawnPos = $spawnPositions.get_child(randi_range(0,$spawnPositions.get_child_count() - 1)).global_position
	#make new robot
	var robotInstance = robot.instantiate()
	#add the robot as a child of this one
	add_child(robotInstance)
	#set the robot's position to the spawn pos that was randomly chosen earlier
	robotInstance.global_position = spawnPos
	robotInstance.health = robotHealth
	robotInstance.moveSpeed = robotSpeed
	robotInstance.navAgent.target_reached.connect(robotReachedTheGoal)
	robotInstance.destroyed.connect(robotDestroyed)
	robotInstance.cannon.target = player
	robotInstance.cannon.canShoot = true
	#for testing, if player assigned, make it look at player
	if(moveTarget != null):
		robotInstance.moveTarget = moveTarget
		
		robotInstance.canMove = true
	else:
		robotInstance.moveTarget = player
		robotInstance.canMove = true
	robotsSpawnedThisWave += 1

func toggleRobotSpawning():
	needToSpawnRobots = !needToSpawnRobots
	if(needToSpawnRobots):
		robotsDestroyedDuringRun = 0
		wavesElapsed = 1
		earnedCredits = 0
		playerCharacter.global_position = defencePosition.global_position
		elevateRobotStats()
		

func robotReachedTheGoal():
	print("script robotSpawner - A Robot has reached the goal, game over or smth idk")
	needToSpawnRobots = false
	print("the player destroyed " + str(robotsDestroyedDuringRun) + " and earned " + str(earnedCredits) + " credits in total")

func robotDestroyed():
	robotsDestroyedDuringRun += 1
	robotsDestroyedThisWave += 1
	earnedCredits += creditAwardAmount * creditAwardAmountModifier
	print("script robotSpawner - The player has destroyed " + str(robotsDestroyedThisWave) + " robots during this wave and " + str(robotsDestroyedDuringRun) + " during the run")

func elevateRobotStats():
	if(wavesElapsed > 1): 
		robotHealth = robotHealthWaveModifier * wavesElapsed
		robotSpeed = robotStartSpeed + (robotSpeedWaveModifier * wavesElapsed)
		robotsPerWave += 1
	else: #if it's the first round, set the start health n stuff
		robotHealth = robotStartHealth
		robotSpeed = robotStartSpeed
	
	#Increase the amount of credits player earns per robot every few rounds
	if(wavesSinceLastIncreasedCreditAwardAmount >= creditAwardIncreaseInterval):
		creditAwardAmountModifier += 1
		wavesSinceLastIncreasedCreditAwardAmount = 0
		print("Increased the credits awarded per robot to " + str(creditAwardAmountModifier))
	else:
		wavesSinceLastIncreasedCreditAwardAmount += 1
	#3 robots per second is pretty good for a maximum spawn speed
	if(robotSpawnInterval > 0.3):
		robotSpawnInterval -= 0.05
	robotsDestroyedThisWave = 0
	giveAmmo.emit()
	print("script robotSpawner - The robotSpeed for the next wave will be " + str(robotSpeed) + " and health will be " + str(robotHealth) + " and we will spawn " + str(robotsPerWave) + " of them")

signal refreshCredits
func onPlayerDied() -> void:
	needToSpawnRobots = false
	for robot in get_children():
		if(robot is breakable):
			robot.queue_free()
	print("the player destroyed " + str(robotsDestroyedDuringRun) + " and earned " + str(earnedCredits) + " credits in total before dying")
	playerCharacter.global_position = basePosition.global_position
	var currentUserCredits = dbConnectionManager.getUserCredits(playerName)
	var totalCredits = currentUserCredits + earnedCredits
	dbConnectionManager.updateUserCredits(playerName, totalCredits)
	refreshCredits.emit()
