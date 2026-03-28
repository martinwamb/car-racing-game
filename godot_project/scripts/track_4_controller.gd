extends Node2D

# Track 4: Arctic Circuit — icy square track with 6 question zones, 6 laps / 210 s.

@onready var player_car = $PlayerCar
@onready var question_popup = $QuestionPopup
@onready var hud = $HUD
@onready var track_manager = $TrackManager
@onready var finish_trigger: Area2D = $FinishTrigger
@onready var question_zones: Node2D = $QuestionZones

const LAP_COOLDOWN = 6.0
var _finish_cooldown: float = LAP_COOLDOWN
var _last_question: Dictionary = {}

func _ready() -> void:
	QuestionMgr.load_all_packs(AgeProfile.age_group if AgeProfile.age_group != "" else "6-8")

	for zone in question_zones.get_children():
		zone.get_node("CollisionShape2D").get_parent().body_entered.connect(
			_on_question_zone_entered.bind(zone)
		)

	question_popup.answered.connect(_on_question_answered)
	question_popup.get_node("Panel/VBox/ContinueBtn").pressed.connect(_on_popup_continue)
	finish_trigger.body_entered.connect(_on_finish_entered)
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
	var coins = CoinSystem.award_race_coins(1, 4)  # track 4 pays the most
	hud.show_coin_popup(coins)
	player_car.freeze()
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
