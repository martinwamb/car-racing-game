extends Node2D

# Wires up the track: question zones → popup → car freeze/unfreeze → HUD.
# Pattern adapted from Dust Racing 2D's event/trigger architecture.

@onready var player_car = $PlayerCar
@onready var question_popup = $QuestionPopup
@onready var hud = $HUD
@onready var track_manager = $TrackManager
@onready var finish_trigger: Area2D = $FinishTrigger
@onready var question_zones: Node2D = $QuestionZones

var _last_finish_side: int = 0   # track which side of finish line car is on
var _last_question: Dictionary = {}

func _ready() -> void:
	# Load all subjects for the player's age group (math + literacy + science)
	QuestionMgr.load_all_packs(AgeProfile.age_group if AgeProfile.age_group != "" else "6-8")

	# Wire question zones
	for zone in question_zones.get_children():
		zone.get_node("CollisionShape2D").get_parent().body_entered.connect(
			_on_question_zone_entered.bind(zone)
		)

	# Wire popup answer signal
	question_popup.answered.connect(_on_question_answered)
	question_popup.get_node("Panel/VBox/ContinueBtn").pressed.connect(_on_popup_continue)

	# Wire finish line
	finish_trigger.body_entered.connect(_on_finish_entered)

	# Wire track manager
	track_manager.time_updated.connect(hud.update_timer)
	track_manager.race_finished.connect(_on_race_finished)

	# Start race
	track_manager.start_race()

func _on_question_zone_entered(body: Node, zone: Node2D) -> void:
	if body != player_car:
		return
	var question = QuestionMgr.get_random_from_all()
	if question.is_empty():
		return
	# Disable zone so it doesn't re-trigger mid-answer
	zone.get_node("CollisionShape2D").disabled = true
	player_car.freeze()
	_last_question = question
	question_popup.show_question(question)
	track_manager.on_question_zone_entered(question)

func _on_question_answered(correct: bool, coins_earned: int) -> void:
	if correct and coins_earned > 0:
		hud.show_coin_popup(coins_earned)
	elif not correct:
		QuestionMgr.mark_failed(_last_question)

func _on_popup_continue() -> void:
	player_car.unfreeze()
	track_manager.on_question_answered()
	# Re-enable all zones for next lap pass
	for zone in question_zones.get_children():
		zone.get_node("CollisionShape2D").disabled = false

func _on_finish_entered(body: Node) -> void:
	if body != player_car:
		return
	# Only count as a lap when crossing front-to-back (not back-to-front)
	var relative_y = player_car.global_position.y - $FinishLine.global_position.y
	if _last_finish_side < 0 and relative_y >= 0:
		track_manager.on_lap_completed()
		var lap_num = track_manager._current_lap
		hud.update_lap(lap_num, track_manager.laps_to_complete)
	_last_finish_side = -1 if relative_y < 0 else 1

func _on_race_finished(position: int) -> void:
	var coins = CoinSystem.award_race_coins(position, 1)
	hud.show_coin_popup(coins)
	player_car.freeze()
	# TODO: transition to race results screen
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
