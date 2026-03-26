extends CanvasLayer

@onready var coins_label: Label = $TopBar/HBoxContainer/CoinsLabel
@onready var timer_label: Label = $TopBar/HBoxContainer/TimerLabel
@onready var lap_label: Label = $TopBar/HBoxContainer/LapLabel
@onready var coin_popup: Label = $CoinPopup

var _popup_tween: Tween

func _ready() -> void:
	coins_label.text = str(AgeProfile.total_coins)
	CoinSystem.coins_changed.connect(_on_coins_changed)

func update_timer(seconds: float) -> void:
	var m = int(seconds) / 60
	var s = int(seconds) % 60
	timer_label.text = "%d:%02d" % [m, s]
	if seconds <= 10.0:
		timer_label.modulate = Color.RED

func update_lap(current: int, total: int) -> void:
	lap_label.text = "Lap %d/%d" % [current, total]

func show_coin_popup(amount: int) -> void:
	if _popup_tween:
		_popup_tween.kill()
	coin_popup.text = "+%d coins!" % amount
	coin_popup.modulate = Color(1, 0.84, 0, 1)
	coin_popup.position.y = 60
	_popup_tween = create_tween()
	_popup_tween.tween_property(coin_popup, "position:y", 20, 0.8)
	_popup_tween.parallel().tween_property(coin_popup, "modulate:a", 0.0, 0.8)

func _on_coins_changed(new_total: int) -> void:
	coins_label.text = str(new_total)
