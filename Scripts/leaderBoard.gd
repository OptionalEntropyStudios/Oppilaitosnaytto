extends StaticBody3D

@onready var rankingTextsLbl: Label3D = $rankingTexts
@onready var currentUserPersonalBestLbl: Label3D = $personalBest
@onready var shotgunKills: Label3D = $shotgunKillsLbl
@onready var pistolKills: Label3D = $pistolKillsLbl
@onready var smgKills: Label3D = $smgKillsLbl
@onready var allKills: Label3D = $allKills

@onready var dbConnectionScript = load("res://Scripts/mySqlTestConneciton.cs")
var dbConnectionManager
var playerName
@export var store : StaticBody3D
func _ready() -> void:
	dbConnectionManager = dbConnectionScript.new()
	await get_tree().create_timer(0.2).timeout
	playerName = store.username
	updateLeaderBoard()
func updateLeaderBoard():
	rankingTextsLbl.text = dbConnectionManager.GetTop10Runs()
	currentUserPersonalBestLbl.text = dbConnectionManager.GetUserPersonalBestRun(playerName)
	getPlayerGunStats()
	getTotalRobotsDestroyedByPlayer()

func getPlayerGunStats():
	var weaponID = playerName + "pistol"
	pistolKills.text = str(dbConnectionManager.GetRobotsDestroyedByWeapon(weaponID))
	weaponID = playerName + "smg"
	smgKills.text = str(dbConnectionManager.GetRobotsDestroyedByWeapon(weaponID))
	weaponID = playerName + "shotgun"
	shotgunKills.text = str(dbConnectionManager.GetRobotsDestroyedByWeapon(weaponID))

func getTotalRobotsDestroyedByPlayer():
	allKills.text = str(dbConnectionManager.GetRobotsDestroyedByPlayer(playerName))
