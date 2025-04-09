extends Node3D

@onready var bullet = preload("res://Scenes/robotBullet.tscn")
@export var gunshotSound : AudioStreamPlayer3D
@export var bulletSpawnPos : Node3D

@export var target : Node3D
var canShoot : bool = false
@export var timeBetweenShots : float = 1.5
@export var timeSinceLastShot = 0.0

func _process(delta: float) -> void:
	if(target != null and canShoot):
		look_at(target.global_position, Vector3.UP)
		if(timeSinceLastShot >= timeBetweenShots):
			timeSinceLastShot = 0.0
			if(randf_range(0,1) > 0.5):
				shoot()
		else: 
			timeSinceLastShot += delta * randf_range(1,2)

func shoot():
	var blt = bullet.instantiate()
	get_tree().root.add_child(blt)
	blt.global_position = bulletSpawnPos.global_position
	blt.look_at(target.global_position, Vector3.UP)
	blt.fired = true
