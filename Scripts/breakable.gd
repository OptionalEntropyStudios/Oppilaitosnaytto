extends CharacterBody3D
class_name breakable

@export var health : int
@export var hitSound : AudioStreamPlayer3D
@export var deathSound : AudioStreamPlayer3D
@export var deathEffect : GPUParticles3D

@export var mesh: MeshInstance3D
@export var hitBox: CollisionShape3D 
@export var headHitBox: CollisionShape3D

signal destroyed
var gotKilled : bool = false
func takeDamage(damage : int , attacker : String):
	health -= damage
	hitSound.play()
	if(health <= 0 and !gotKilled):
		die(attacker)
		hitBox.disabled = true


func die(killer : String):
	gotKilled = true
	destroyed.emit(killer)
	deathSound.play()
	deathEffect.emitting = true
	for child in get_children():
		if(child is not GPUParticles3D and child is not AudioStreamPlayer3D):
			child.queue_free()

func onDeathEffectFinished():
	queue_free()
