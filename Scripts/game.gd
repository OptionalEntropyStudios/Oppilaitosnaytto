extends Node3D

var xrInterface: XRInterface

func _ready() -> void:
	xrInterface = XRServer.find_interface("OpenXR")
	
	if xrInterface and xrInterface.is_initialized(): #checks if xrInterface is assigned to anything and initialized
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED) #Disable vsync for the vr view
	
	get_viewport().use_xr = true #Shows the pov of vr-goggles on the monitor as well
