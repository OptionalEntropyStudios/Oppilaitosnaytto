extends Node3D


signal giveAmmo


signal resetGunAccuracyCounters

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
var robotsPerWave : int = 8
var robotsSpawnedThisWave : int = 0
var robotsDestroyedThisWave : int = 0
var earnedCredits : int = 0
var creditAwardAmount : int = 1
var creditAwardAmountModifier : int = 1
var healthPacksUsedByThePlayer : int = 0
var playerAccuracy : float
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
var dbConnectionManager
func _ready() -> void:
	timeSinceLastRobotSpawned = 0.0
	await get_tree().create_timer(0.5).timeout
	playerName = playerCharacter.username
	dbConnectionManager = get_tree().get_first_node_in_group("sql")
func _process(delta: float) -> void:
	if(needToSpawnRobots):
		if(timeSinceLastRobotSpawned > robotSpawnInterval):
			timeSinceLastRobotSpawned = 0.0
			if(robotsSpawnedThisWave < robotsPerWave):
				spawnRobot()
			else:
				if(robotsDestroyedThisWave >= robotsSpawnedThisWave):
					robotsSpawnedThisWave = 0
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
	robotInstance.navAgent.navigation_finished.connect(robotReachedTheGoal)
	robotInstance.destroyed.connect(robotDestroyed)
	robotInstance.cannon.target = player
	robotInstance.cannon2.target = player
	robotInstance.cannon.canShoot = true
	robotInstance.cannon2.canShoot = true
	#for testing, if player assigned, make it look at player
	if(moveTarget != null):
		robotInstance.moveTarget = moveTarget
	else:
		robotInstance.moveTarget = player
	robotInstance.canMove = true
	#robotInstance.hitSound.play()
	robotsSpawnedThisWave += 1

func toggleRobotSpawning():
	needToSpawnRobots = !needToSpawnRobots
	if(needToSpawnRobots):
		startRun()
signal hurtPlayer
func robotReachedTheGoal():
		needToSpawnRobots = false
		var i = 0
		var damage = 20
		while i < 5:
			hurtPlayer.emit(damage)
			i += 1

func robotDestroyed(gunThatKilledIt : String):
	robotsDestroyedDuringRun += 1
	robotsDestroyedThisWave += 1
	trackRobotsKilledByDifferentGunsThisRun(gunThatKilledIt)
	earnedCredits += creditAwardAmount * creditAwardAmountModifier

var pistolKills : int = 0
var smgKills : int = 0
var shotgunKills : int = 0
func trackRobotsKilledByDifferentGunsThisRun(weapon : String):
	if(weapon == "pistol"):
		pistolKills += 1
	if(weapon == "smg"):
		smgKills += 1
	if(weapon == "shotgun"):
		shotgunKills += 1

func resetTrackedGunStats():
	pistolKills = 0
	smgKills = 0
	shotgunKills = 0
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
	else:
		wavesSinceLastIncreasedCreditAwardAmount += 1
	#3 robots per second is pretty good for a maximum spawn speed
	if(robotSpawnInterval > 0.3):
		robotSpawnInterval -= 0.05
	robotsDestroyedThisWave = 0
	giveAmmo.emit(false) #false means that it's not the start of game, and just add some

signal refreshCredits
func onPlayerDied(accuracy : float) -> void:
	gameOver(accuracy)

func onPlayerUsedHealthPack():
	healthPacksUsedByThePlayer += 1

func countPlayerScore(accuracy : float) -> float:
	var accuracyMultiplier = accuracy / 10 #aka 95% accuracy would be 9.5%
	var score : float
	if(healthPacksUsedByThePlayer > 0):
		var healthPacksUsedPenalty = 1
		for i in range(healthPacksUsedByThePlayer, 0, -1):
			healthPacksUsedPenalty -= 0.05
		if(healthPacksUsedPenalty < 0):
			healthPacksUsedPenalty = 0.3
		score = (((wavesElapsed * accuracyMultiplier) + (robotsDestroyedDuringRun * 1.5)) * healthPacksUsedPenalty) * 10
	else: 
		score = (wavesElapsed * accuracyMultiplier) + (robotsDestroyedDuringRun * 1.5)
	return score

func startRun():
	robotsDestroyedDuringRun = 0
	robotsSpawnedThisWave = 0
	wavesElapsed = 1
	earnedCredits = 0
	healthPacksUsedByThePlayer = 0
	resetGunAccuracyCounters.emit()
	playerCharacter.global_position = defencePosition.global_position
	playerCharacter.health = playerCharacter.maxHealth
	resetTrackedGunStats()
	elevateRobotStats()
	giveAmmo.emit(true) #True means that it's the start of game, so the ammo will be the starting amount

func gameOver(accuracy : float):
	needToSpawnRobots = false
	if(accuracy > 100.0):
		accuracy = 100.0
	playerAccuracy = accuracy
	for rbt in get_children():
		if(rbt is breakable):
			rbt.queue_free()
	dbConnectionManager.AddNewRunEntry(playerName, wavesElapsed, countPlayerScore(playerAccuracy), playerAccuracy)
	playerCharacter.global_position = basePosition.global_position
	var currentUserCredits = dbConnectionManager.getUserCredits(playerName)
	var totalCredits = currentUserCredits + earnedCredits
	dbConnectionManager.updateUserCredits(playerName, totalCredits)
	updateGunRobotKills()
	updatePlayerAccuracy()
	updatePlayerRobotKills()
	refreshCredits.emit()
func updatePlayerRobotKills():
	dbConnectionManager.UpdatePlayerRobotsDestroyedAmount(playerName, robotsDestroyedDuringRun)
func updateGunRobotKills():
	dbConnectionManager.UpdateWeaponDestroyedRobotsAmount(playerName, "pistol", pistolKills)
	dbConnectionManager.UpdateWeaponDestroyedRobotsAmount(playerName, "smg", smgKills)
	dbConnectionManager.UpdateWeaponDestroyedRobotsAmount(playerName, "shotgun", shotgunKills)

func updatePlayerAccuracy():
	dbConnectionManager.UpdatePlayerAccuracy(playerName)
