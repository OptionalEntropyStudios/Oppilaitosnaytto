extends Control

var targetGun = ""
var username = ""
var dbConnectionManager
@onready var gunName: LineEdit = $gunNameLEdit
func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("pause") and visible):
		continuegame()

func openMenu():
	get_tree().paused = true
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED) 

func continuegame():
	get_tree().paused = false
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 

func changeName():
	print("trying to change name")
	if(!gunName.text.is_empty()):
		dbConnectionManager.ChangeWeaponName(username, targetGun, gunName.text)
		continuegame()
	else: print(" this shit empty")


func _on_gun_name_l_edit_editing_toggled(toggled_on: bool) -> void:
	print("the text is being edited")
