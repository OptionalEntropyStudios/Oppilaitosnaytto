extends Node3D

var dbConnectionScript = preload("res://Scripts/mySqlTestConneciton.cs")
var dbConnectionManager

var ownedHealthPacksAmount : int
@export var healAmount : int
@export var player : CharacterBody3D
@onready var healthPacksIndicatorLbl: Label = $"../playerUI/healthPackIndicator/healthPacksAmtIndicator"
@onready var healIndicator: ColorRect = $"../playerUI/healIndicator"

func _ready() -> void:
	dbConnectionManager = dbConnectionScript.new()
	await get_tree().create_timer(0.5).timeout
	checkOwnedHealthPacks()
func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("heal")):
		heal()
	if(healIndicator.color.a > 0.0):
		healIndicator.color.a -= delta * 1
func heal():
	if(ownedHealthPacksAmount > 0 and player.health < player.maxHealth):
		ownedHealthPacksAmount -= 1
		dbConnectionManager.updateOwnedEquipmentAmount(player.username, "health", ownedHealthPacksAmount)
		player.health += healAmount
		healIndicator.color.a += .4
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
