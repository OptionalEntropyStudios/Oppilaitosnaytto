extends StaticBody3D
class_name button

@onready var collider: CollisionShape3D = $buttonCollider

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

#If the button is not visible, the collider needs to be disabled, so the button cannot be pressed
func _on_visibility_changed() -> void:
	if(visible):
		collider.disabled = false
	else: collider.disabled = true
