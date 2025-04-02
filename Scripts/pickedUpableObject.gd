extends RigidBody3D
class_name pickUpableObject

@export var canBePickedUp : bool
var baseGravity
var isHeld : bool
var holder
func _ready() -> void:
	baseGravity = gravity_scale

	isHeld = false
func getYeeted() -> void:
	isHeld = false
	gravity_scale = 1.0
func getYoinked(yoinker) -> void:
	if(yoinker.is_class("XRController3D")):
		self.gravity_scale = 0
		isHeld = true
		global_position = yoinker.global_position
		rotation = yoinker.rotation
