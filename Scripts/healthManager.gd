extends Node3D

var dbConnectionManager

var ownedHealthPacksAmount : int
@export var healAmount : int
@export var player : CharacterBody3D
@onready var healthPacksIndicatorLbl: Label = $"../playerUI/healthPackIndicator/healthPacksAmtIndicator"
@onready var healIndicator: ColorRect = $"../playerUI/healIndicator"
@onready var healSound: AudioStreamPlayer3D = $"../healSound"

func _ready() -> void:
	dbConnectionManager = get_tree().get_first_node_in_group("sql")
	await get_tree().create_timer(0.5).timeout
	checkOwnedHealthPacks()
func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("heal")):
		heal()
	if(healIndicator.color.a > 0.0):
		healIndicator.color.a -= delta * .85
func heal():
	if(ownedHealthPacksAmount > 0 and player.health < player.maxHealth):
		ownedHealthPacksAmount -= 1
		dbConnectionManager.updateOwnedEquipmentAmount(player.username, "health", ownedHealthPacksAmount)
		player.health += healAmount
		healIndicator.color.a += .4
		if(healIndicator.color.a > .7):
			healIndicator.color.a = .7
		healSound.play()
		if(player.health > player.maxHealth):
			player.health = player.maxHealth
		player.healthCounter.text = str(player.health)
		player.usedHealthPack.emit()
		updateHealthPackIndicator()

func checkOwnedHealthPacks():
	ownedHealthPacksAmount = dbConnectionManager.getOwnedEquipmentAmount(player.username, "health")
	updateHealthPackIndicator()

func updateHealthPackIndicator():
	healthPacksIndicatorLbl.text = "+ " + str(ownedHealthPacksAmount)
