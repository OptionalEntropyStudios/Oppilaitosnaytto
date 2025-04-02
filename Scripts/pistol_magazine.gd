extends XRToolsPickable

class_name pistolMagazine

@onready var bullet1: MeshInstance3D = $magazine/bullet1
@export var magazineCapacity = 12
var bulletsLeft = 12
func hasBullets() -> bool:
	return bulletsLeft > 0

func ejectBullet():
	if hasBullets():
		bulletsLeft-= 1
		updateBulletMesh()

func updateBulletMesh():
	bullet1.visible = hasBullets()
