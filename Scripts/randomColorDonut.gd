extends Node3D

@onready var donut: MeshInstance3D = $donut
func changeDonutColor():
	var randNro1 = randf_range(0, 1)
	var randNro2 = randf_range(0, 1)
	var randNro3= randf_range(0, 1)
	var randNro4 = randf_range(0, 1)
	var randomColor = Color(randNro1, randNro2, randNro3, randNro4)
	donut.mesh.material.albedo_color = randomColor
