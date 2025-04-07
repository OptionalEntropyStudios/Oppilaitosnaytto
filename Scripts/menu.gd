extends Node3D
class_name menu

var selected : bool = false

func _ready() -> void:
	visible = selected

func select():
	selected = true
	visible = selected

func deSelect():
	selected = false
	visible = selected
