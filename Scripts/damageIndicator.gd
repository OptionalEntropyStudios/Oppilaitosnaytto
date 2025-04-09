extends Node3D
var damageAmount
@export var fontSize : int = 50
@export var elevationSpeed : float = 15
@export var damageText: Label3D
var spawned = false
@export var rainbowText : bool = false
var timeSinceLastFontDecrease : float = 0.0
func _process(delta: float) -> void:
	if(!spawned):
		damageText.font_size = fontSize
		if(rainbowText):
			var r = randf_range(0, 1)
			var g = randf_range(0, 1)
			var b = randf_range(0, 1)
			damageText.modulate = Color(r,g,b)
		spawned = true
	else:
		damageText.global_position.y += elevationSpeed * delta
		if(damageText.global_position.y > 7.0):
			queue_free()
