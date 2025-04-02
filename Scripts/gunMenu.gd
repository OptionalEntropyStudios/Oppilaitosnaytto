extends Node3D

enum availableGuns {PISTOL, SMG, SHOTGUN, HAND = -1}

var selectedGun

func selectPistol(object):
	if(visible):
		selectedGun = availableGuns.PISTOL
		print("set selected gun to pistol and the value is " + str(selectedGun))
func selectSMG(object):
	if(visible):
		selectedGun = availableGuns.SMG
		print("set selected gun to smg and the value is " + str(selectedGun))
func selectSHOTGUN(object):
	if(visible):
		selectedGun = availableGuns.SHOTGUN
		print("set selected gun to shotgun and the value is " + str(selectedGun))
func selectHAND(object):
	if(visible):
		selectedGun = availableGuns.HAND
		print("set selected gun to hand and the value is " + str(selectedGun))
