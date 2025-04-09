extends Node3D


func _on_visibility_changed() -> void:
		for child in get_children(true):
			print(self.name + " is turning the visibility of " + child.name + " to " + str(self.visible))
			child.visible = self.visible

			child.reportVisibilityStatus()
