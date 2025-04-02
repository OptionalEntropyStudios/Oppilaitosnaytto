extends pickUpableObject
class_name pistolMagazine

var bulletsLeft : int = 8

@onready var holderDetector: Area3D = $holderDetector
var isInserted
var gunHoldingThisMagazine
var meshStartLocalPos
@onready var magMesh: MeshInstance3D = $magMesh
func _ready():
	meshStartLocalPos = magMesh.position
func removeBullet()-> void:
	if(bulletsLeft > 0):
		bulletsLeft -= 1

func _physics_process(delta: float) -> void:
	if(isInserted):
		updatePosition(gunHoldingThisMagazine)
	else:
		magMesh.position = meshStartLocalPos
func updatePosition(holder) -> void:
	var magHolder = holder.get_node("magazineHolder")
	global_position = magHolder.global_position
	self.global_rotation = magHolder.global_rotation
	magMesh.position.x = meshStartLocalPos.x - 0.07
func getDropped():
	if(isInserted):
		isInserted = false

func getLoaded(gunBeingLoaded):
	print("The magazine has collided with " + gunBeingLoaded.name)
	if(gunBeingLoaded.is_in_group("pistol")):
		print("We have hit a pistol")
		gunHoldingThisMagazine = gunBeingLoaded
		canBePickedUp = false
		isHeld = false
		isInserted = true
