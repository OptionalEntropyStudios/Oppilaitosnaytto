extends StaticBody3D
class_name button

@onready var collider: CollisionShape3D = $buttonCollider

@export var enabled : bool = true
@onready var enabledPosition: Node3D = $enabledPosition
@onready var disabledPosition: Node3D = $disabledPosition

signal buttonPressed
@export var textOnTheButton : String
@onready var buttonText: Label3D = $buttonMesh/buttonText
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var pressedSound: AudioStreamPlayer3D = $pressedSound

func _ready() -> void:
	buttonText.text = textOnTheButton
	await get_tree().create_timer(0.5).timeout
	checkPressability()
func press():
	if(!animationPlayer.is_playing()):
		animationPlayer.play("pressed")
		pressedSound.play()
		buttonPressed.emit()

#If the button is not visible, the collider needs to be disabled, so the button cannot be pressed
func _on_visibility_changed() -> void:
	pass
	if(visible):
		collider.disabled = false
	else: collider.disabled = true

func checkPressability():
	if(enabled):
		collider.position = enabledPosition.position
	else:
		collider.position = disabledPosition.position
	visible = enabled
