extends Node3D

@onready var mesh: MeshInstance3D = $hitHoleMesh
@export var disappearTime : float = 5.0
var elapsedTime : float = 0.0
var hitEffectPlayed : bool = false
@onready var hitEffect: GPUParticles3D = $hitEffect
@onready var hitSound: AudioStreamPlayer3D = $hitSound


func _process(delta: float) -> void:
	elapsedTime += delta
	if(!hitEffectPlayed):
		hitEffectPlayed = true
		hitSound.play()
		hitEffect.emitting = true
	if(elapsedTime > disappearTime):
		queue_free()
