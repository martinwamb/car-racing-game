extends Node

signal coins_changed(new_total: int)
signal upgrade_purchased(upgrade_id: String)

const UPGRADES = {
	"engine_1":  {"name": "Engine Upgrade",     "cost": 100, "description": "Faster top speed"},
	"tires_1":   {"name": "Better Tires",       "cost":  80, "description": "Tighter cornering"},
	"skin_1":    {"name": "Red Car",            "cost":  50, "description": "New car colour"},
	"skin_2":    {"name": "Blue Car",           "cost":  50, "description": "New car colour"},
	"track_2":   {"name": "City Night Circuit", "cost": 200, "description": "Unlock Track 2"},
	"track_3":   {"name": "Desert Circuit",     "cost": 350, "description": "Unlock Track 3"},
	"track_4":   {"name": "Arctic Circuit",     "cost": 500, "description": "Unlock Track 4"},
	"time_ext":  {"name": "+30s Race Time",     "cost":  30, "description": "Extend current race"},
}

var _owned_upgrades: Array = []

func _ready() -> void:
	_load_upgrades()

# Called when a question is answered correctly
func award_question_coins(difficulty: int) -> int:
	var amount = 10 * difficulty  # difficulty 1-5
	AgeProfile.add_coins(amount)
	coins_changed.emit(AgeProfile.total_coins)
	return amount

func award_race_coins(position: int, total_racers: int) -> int:
	var base = 20
	# Bonus for good finishing position
	var bonus = max(0, (total_racers - position)) * 10
	var amount = base + bonus
	AgeProfile.add_coins(amount)
	coins_changed.emit(AgeProfile.total_coins)
	return amount

func purchase(upgrade_id: String) -> bool:
	if upgrade_id not in UPGRADES:
		return false
	if upgrade_id in _owned_upgrades:
		return false
	var cost = UPGRADES[upgrade_id]["cost"]
	if AgeProfile.spend_coins(cost):
		_owned_upgrades.append(upgrade_id)
		_save_upgrades()
		coins_changed.emit(AgeProfile.total_coins)
		upgrade_purchased.emit(upgrade_id)
		return true
	return false

func owns(upgrade_id: String) -> bool:
	return upgrade_id in _owned_upgrades

func _save_upgrades() -> void:
	var cfg = ConfigFile.new()
	cfg.load("user://profile.cfg")
	cfg.set_value("upgrades", "owned", _owned_upgrades)
	cfg.save("user://profile.cfg")

func _load_upgrades() -> void:
	var cfg = ConfigFile.new()
	if cfg.load("user://profile.cfg") != OK:
		return
	_owned_upgrades = cfg.get_value("upgrades", "owned", [])
