extends Label3D
@onready var databaseConnector: Node = $"../databaseConnector"

func _ready() -> void:
	text = "Tähän ilmestyy pelaajan data :)"
	await get_tree().create_timer(10).timeout
	text = databaseConnector.userStats
