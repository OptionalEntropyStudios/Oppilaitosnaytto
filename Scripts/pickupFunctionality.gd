extends XRController3D

@onready var grabDetection: Area3D = $pickupDetection
var targetObject : pickUpableObject = null

func _process(delta: float) -> void:
	if(get_input("grip_click") and targetObject != null):
		if(targetObject.canBePickedUp):
			visible = false
			targetObject.getYoinked(self)
	elif(targetObject != null):
		visible = true
		targetObject.getYeeted()
func onObjectEntered(object):
	targetObject = object

func onObjectExited(object):
	targetObject = null
