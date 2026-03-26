extends Node

# Persists the player's chosen age group across sessions
# Age groups: "3-5", "6-8", "9-11", "12+"

const SAVE_PATH = "user://profile.cfg"

var age_group: String = ""
var player_name: String = "Player"
var total_coins: int = 0

func _ready() -> void:
	load_profile()

func set_age_group(group: String) -> void:
	age_group = group
	save_profile()

func add_coins(amount: int) -> void:
	total_coins += amount
	save_profile()

func spend_coins(amount: int) -> bool:
	if total_coins >= amount:
		total_coins -= amount
		save_profile()
		return true
	return false

func save_profile() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("profile", "age_group", age_group)
	cfg.set_value("profile", "player_name", player_name)
	cfg.set_value("profile", "total_coins", total_coins)
	cfg.save(SAVE_PATH)

func load_profile() -> void:
	var cfg = ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	age_group = cfg.get_value("profile", "age_group", "")
	player_name = cfg.get_value("profile", "player_name", "Player")
	total_coins = cfg.get_value("profile", "total_coins", 0)
