extends Node3D

@onready var mesh: MeshInstance3D = $hitHoleMesh
@export var disappearTime : float = 5.0
var elapsedTime : float = 0.0
func _process(delta: float) -> void:
	elapsedTime += delta
	if(elapsedTime > disappearTime):
		queue_free()
