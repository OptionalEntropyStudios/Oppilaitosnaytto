extends Node3D

@onready var robot = preload("res://Scenes/robot1_breakable.tscn")

var spawnPositions

@export var player : CharacterBody3D
func spawnRobot():
	var spawnPos = $spawnPositions.get_child(randi_range(0,$spawnPositions.get_child_count() - 1)).global_position
	var robotInstance = robot.instantiate()
	add_child(robotInstance)
	robotInstance.global_position = spawnPos
	if(player != null):
		var targetPos = Vector3(player.global_position.x, robotInstance.global_position.y, player.global_position.z)
		robotInstance.look_at(targetPos, Vector3.UP)
	print("Spawned " + robotInstance.name + " in "+ str(spawnPos))
