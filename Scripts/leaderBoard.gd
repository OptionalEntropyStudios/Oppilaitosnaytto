extends StaticBody3D

@onready var rankingTextsLbl: Label3D = $rankingTexts
@onready var currentUserPersonalBestLbl: Label3D = $personalBest
@onready var shotgunKills: Label3D = $shotgunKillsLbl
@onready var pistolKills: Label3D = $pistolKillsLbl
@onready var smgKills: Label3D = $smgKillsLbl
@onready var allKills: Label3D = $allKills
@onready var avgAccuracyLbl: Label3D = $averageAccuracyLabel


var dbConnectionManager
var playerName
@export var store : StaticBody3D
func _ready() -> void:
	dbConnectionManager = get_tree().get_first_node_in_group("sql")
	await get_tree().create_timer(0.2).timeout
	playerName = store.username
	updateLeaderBoard()
func updateLeaderBoard():
	rankingTextsLbl.text = dbConnectionManager.GetTop10Runs()
	currentUserPersonalBestLbl.text = dbConnectionManager.GetUserPersonalBestRun(playerName)
	getPlayerGunStats()
	getTotalRobotsDestroyedByPlayer()
	getPlayerAverageAccuracy()

func getPlayerGunStats():
	var weaponID = playerName + "pistol"
	pistolKills.text = str(dbConnectionManager.GetRobotsDestroyedByWeapon(weaponID))
	weaponID = playerName + "smg"
	smgKills.text = str(dbConnectionManager.GetRobotsDestroyedByWeapon(weaponID))
	weaponID = playerName + "shotgun"
	shotgunKills.text = str(dbConnectionManager.GetRobotsDestroyedByWeapon(weaponID))

func getTotalRobotsDestroyedByPlayer():
	allKills.text = "all kills  :" + str(dbConnectionManager.GetRobotsDestroyedByPlayer(playerName))

func getPlayerAverageAccuracy():
	avgAccuracyLbl.text = "Average accuracy = " + str(dbConnectionManager.GetPlayerAverageAccuracy(playerName)) + "%"
