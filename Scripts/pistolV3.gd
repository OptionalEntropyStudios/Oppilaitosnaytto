extends XRToolsPickable
class_name pistolV3

var equipped : bool = false
var loadedMagazine

@onready var animationPlayer = $AnimationPlayer
@onready var magSnapZone = $MagazineSnapZone

@export var hand : XRController3D
@export var pistolRotPos : Node3D
func _process(delta: float) -> void:
	equipped = visible
func shoot():
	pass
func _physics_process(delta: float) -> void:
	self.global_position = pistolRotPos.global_position
	self.rotation = pistolRotPos.rotation
func onMagazineEjected():
	magSnapZone.drop_object()
	loadedMagazine = null
	pass

func onMagazineLoaded():
	pass

func onMagazineSnapZonePickedSomethingUP(pickedUpobject):
	animationPlayer.play("loadMagazine")
	
	loadedMagazine = pickedUpobject
	pass

func triggerPressed():
	if(equipped):
		animationPlayer.play("shoot")

func ejectButtonPressed():
	if(equipped):
		if(loadedMagazine != null):
			animationPlayer.play("ejectMagazine")
