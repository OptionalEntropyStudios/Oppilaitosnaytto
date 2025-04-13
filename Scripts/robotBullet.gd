extends RigidBody3D

var fired : bool = false
@export var wibblyWobblySound: AudioStreamPlayer3D
@onready var hitSound: AudioStreamPlayer3D = $hitSound
@onready var hitEffect: GPUParticles3D = $hitEffect

var startedSound : bool = false
var hitSomething : bool = false
@export var minDamage : int
@export var maxDamage : int
@export var speed : float = 1
@onready var mesh: MeshInstance3D = $bulletMesh

var lifetimeLimit : float = 10
var lifetime : float = 0


func _physics_process(delta: float) -> void:
	if(fired):
		if(!startedSound):
			startedSound = true
			wibblyWobblySound.play()
		apply_force(-transform.basis.z * speed, transform.basis.z)
		lifetime += delta
		if(lifetime > lifetimeLimit):
			queue_free()
		if(hitSomething and wibblyWobblySound.is_playing()):
			wibblyWobblySound.stop()

func bulletHitSomething(body: Node3D) -> void:
	if(body is breakable):
		pass
	if(body.is_in_group("player")):
		var damage = randi_range(minDamage, maxDamage)
		body.takeDamage(damage)
	mesh.hide()
	hitSomething = true
	hitEffect.emitting = true
	hitSound.play()



func onWibblyWobblyFinished() -> void:
	wibblyWobblySound.play()


func onHitSoundFinished() -> void:
	queue_free()
