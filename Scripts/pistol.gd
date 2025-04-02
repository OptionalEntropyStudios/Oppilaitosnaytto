extends Node3D
class_name pistol

@onready var magHolder: Area3D = $magazineHolder
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
var isTriggerReset : bool = false
var isSlideReset : bool = false

var hasMagazine : bool = false
var loadedMagazine

func _ready() -> void:
	hasMagazine = false
	isSlideReset = true
	isTriggerReset = true
func shoot():
	if(isTriggerReset and isSlideReset and visible):
		print("Man if we had ammo, we'd be bustin caps left n right rn ongong")
		animationPlayer.play("shootGun")
		isTriggerReset = false
		isSlideReset = false

func resetSlide():
	isSlideReset = true

func resetTrigger():
	isTriggerReset = true

func loadMagazine(object):
	if(visible):
		var parent = object.get_parent()
		if(!hasMagazine):
			if(parent.is_in_group("pistolMagazine")):
				hasMagazine = true
				parent.getLoaded(self)
				print("pistol has detected a magazine and has loaded it")
				animationPlayer.play("loadMagazine")
				loadedMagazine = parent

func ejectMagazine():
	print("The pistol will drop the loaded magazine now")
	hasMagazine = false
	magHolder.monitoring = false
	magHolder.monitorable = false
	loadedMagazine.getDropped()
	loadedMagazine.canBePickedUp = true
	loadedMagazine = null
	await(get_tree().create_timer(0.5).timeout)
	magHolder.monitorable = true
	magHolder.monitorable = true

func ejectButtonpressed():
	if(loadedMagazine != null):
		animationPlayer.play("ejectMagazine")
