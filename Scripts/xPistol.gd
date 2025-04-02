@tool
extends XRToolsPickable

var loadedMagazine
@onready var magazineHolder: XRToolsSnapZone = $magazineSnapZone

@onready var animPlayer: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if(magazineHolder.enabled):
		print("THe snapzone should be enabled an able to pick shit up")
	else: print("THe snapzone is not enabled wtf")
func onMagEjected():
	print("Player ejected magazine")
	magazineHolder.drop_object()
	loadedMagazine = null
func onMagLoaded():
	print("The magazine has been loaded")

func onMagInserted(what: Variant) -> void:
	print("A magazine has been inserted")
	animPlayer.play("loadMagazine")
	loadedMagazine = what
func _process(delta: float) -> void:
	var controllerHoldingThisObject = get_picked_up_by_controller()
	if(controllerHoldingThisObject != null and controllerHoldingThisObject.get_input("ax_button")):
		if(loadedMagazine != null):
			animPlayer.play("ejectMagazine")
			print("Ay we ejecting the mag now")
