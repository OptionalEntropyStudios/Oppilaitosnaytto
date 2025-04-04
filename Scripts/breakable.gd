extends CharacterBody3D
class_name breakable

@export var health : int
@export var hitSound : AudioStreamPlayer3D
@export var deathSound : AudioStreamPlayer3D
@export var deathEffect : GPUParticles3D

@onready var mesh: MeshInstance3D = $robot1Mesh
@onready var hitBox: CollisionShape3D = $hitBox
func takeDamage(damage : int):
	health -= damage
	hitSound.play()
	if(health <= 0):
		die()
		hitBox.disabled = true


func die():
	deathSound.play()
	deathEffect.emitting = true
	for child in get_children():
		if(child.is_in_group("decal")):
			child.queue_free()
	mesh.visible = false
	

func onDeathEffectFinished():
	queue_free()
