extends StaticBody3D
class_name button

signal buttonPressed
@export var textOnTheButton : String
@onready var buttonText: Label3D = $buttonMesh/buttonText
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
func _ready() -> void:
	buttonText.text = textOnTheButton
func press():
	if(!animationPlayer.is_playing()):
		animationPlayer.play("pressed")
		buttonPressed.emit()
