extends Camera3D

@export var lookSensitivity : float = 150.0
@onready var player: CharacterBody3D = $".."

var canLook : bool = false
func _input(event: InputEvent) -> void:
	if(event is InputEventMouseMotion):
		if(canLook):
			rotate_x(deg_to_rad(-event.relative.y * lookSensitivity * get_process_delta_time()))
			player.rotate_y(deg_to_rad(-event.relative.x * lookSensitivity * get_process_delta_time()))

func _process(delta: float) -> void:
	rotation_degrees.x = clampf(rotation_degrees.x, -90.0, 90.0)

func onLevelLoaded():
	canLook = true
