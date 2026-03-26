extends Node

# Manages race state: timer, lap counting, question zones, race end.

signal race_finished(position: int)
signal question_zone_triggered(question: Dictionary)
signal time_updated(seconds_remaining: float)

@export var race_duration: float = 120.0  # seconds
@export var laps_to_complete: int = 3

var _time_remaining: float = 0.0
var _current_lap: int = 0
var _race_active: bool = false
var _paused_for_question: bool = false

func start_race() -> void:
	_time_remaining = race_duration
	_current_lap = 0
	_race_active = true

func _process(delta: float) -> void:
	if not _race_active or _paused_for_question:
		return
	_time_remaining -= delta
	time_updated.emit(_time_remaining)
	if _time_remaining <= 0.0:
		_end_race()

func add_time(seconds: float) -> void:
	_time_remaining += seconds

func on_lap_completed() -> void:
	_current_lap += 1
	if _current_lap >= laps_to_complete:
		_end_race()

func on_question_zone_entered(question: Dictionary) -> void:
	_paused_for_question = true
	question_zone_triggered.emit(question)

func on_question_answered() -> void:
	_paused_for_question = false

func _end_race() -> void:
	_race_active = false
	race_finished.emit(1)  # position — AI opponents to be added later
