extends Node3D

@onready var robot = preload("res://Scenes/robot1_breakable.tscn")

var spawnPositions
@export var moveTarget : Node3D
@export var player : CharacterBody3D
var needToSpawnRobots : bool = false
var timeSinceLastRobotSpawned : float

@export var robotSpawnInterval : float

func _ready() -> void:
	timeSinceLastRobotSpawned = 0.0
func _process(delta: float) -> void:
	if(needToSpawnRobots):
		if(timeSinceLastRobotSpawned > robotSpawnInterval):
			timeSinceLastRobotSpawned = 0.0
			spawnRobot()
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
	#for testing, if player assigned, make it look at player
	if(moveTarget != null):
		robotInstance.moveTarget = moveTarget
		robotInstance.canMove = true
	else:
		robotInstance.moveTarget = player
		robotInstance.canMove = true

func toggleRobotSpawning():
	needToSpawnRobots = !needToSpawnRobots


func robotDestroyed():
	pass
