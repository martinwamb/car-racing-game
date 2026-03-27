extends Node2D

# Wires up Track 2 (City Night Circuit): question zones → popup → car → HUD.
# Uses a cooldown-based finish-line counter that works reliably with Godot's
# body_entered signal (fired once on entry, not on exit).

@onready var player_car = $PlayerCar
@onready var question_popup = $QuestionPopup
@onready var hud = $HUD
@onready var track_manager = $TrackManager
@onready var finish_trigger: Area2D = $FinishTrigger
@onready var question_zones: Node2D = $QuestionZones

const LAP_COOLDOWN = 6.0   # minimum seconds between lap counts
var _finish_cooldown: float = LAP_COOLDOWN  # start with cooldown so spawn doesn't count

func _ready() -> void:
	QuestionMgr.load_all_packs(AgeProfile.age_group if AgeProfile.age_group != "" else "6-8")

	# Wire question zones
	for zone in question_zones.get_children():
		zone.get_node("CollisionShape2D").get_parent().body_entered.connect(
			_on_question_zone_entered.bind(zone)
		)

	# Wire popup
	question_popup.answered.connect(_on_question_answered)
	question_popup.get_node("Panel/VBox/ContinueBtn").pressed.connect(_on_popup_continue)

	# Wire finish line
	finish_trigger.body_entered.connect(_on_finish_entered)

	# Wire track manager
	track_manager.time_updated.connect(hud.update_timer)
	track_manager.race_finished.connect(_on_race_finished)

	track_manager.start_race()

func _process(delta: float) -> void:
	if _finish_cooldown > 0.0:
		_finish_cooldown -= delta

func _on_question_zone_entered(body: Node, zone: Node2D) -> void:
	if body != player_car:
		return
	var question = QuestionMgr.get_random_from_all()
	if question.is_empty():
		return
	zone.get_node("CollisionShape2D").disabled = true
	player_car.freeze()
	question_popup.show_question(question)
	track_manager.on_question_zone_entered(question)

func _on_question_answered(correct: bool, coins_earned: int) -> void:
	if correct and coins_earned > 0:
		hud.show_coin_popup(coins_earned)

func _on_popup_continue() -> void:
	player_car.unfreeze()
	track_manager.on_question_answered()
	for zone in question_zones.get_children():
		zone.get_node("CollisionShape2D").disabled = false

func _on_finish_entered(body: Node) -> void:
	if body != player_car or _finish_cooldown > 0.0:
		return
	_finish_cooldown = LAP_COOLDOWN
	track_manager.on_lap_completed()
	var lap_num = track_manager._current_lap
	hud.update_lap(lap_num, track_manager.laps_to_complete)

func _on_race_finished(_position: int) -> void:
	var coins = CoinSystem.award_race_coins(1, 2)  # track 2 pays slightly more
	hud.show_coin_popup(coins)
	player_car.freeze()
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
