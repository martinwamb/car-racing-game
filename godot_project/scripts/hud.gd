extends CanvasLayer

@onready var coins_label: Label = $TopBar/HBoxContainer/CoinsLabel
@onready var timer_label: Label = $TopBar/HBoxContainer/TimerLabel
@onready var lap_label: Label = $TopBar/HBoxContainer/LapLabel
@onready var coin_popup: Label = $CoinPopup
@onready var _accel_btn: Button = $TouchControls/AccelBtn
@onready var _brake_btn: Button = $TouchControls/BrakeBtn
@onready var _left_btn: Button = $TouchControls/TurnLeftBtn
@onready var _right_btn: Button = $TouchControls/TurnRightBtn

var _popup_tween: Tween

func _ready() -> void:
	coins_label.text = str(AgeProfile.total_coins)
	CoinSystem.coins_changed.connect(_on_coins_changed)

	# Wire touch buttons → Input action press/release so car_controller.gd needs no changes
	_accel_btn.button_down.connect(func(): Input.action_press("accelerate"))
	_accel_btn.button_up.connect(func(): Input.action_release("accelerate"))
	_brake_btn.button_down.connect(func(): Input.action_press("brake"))
	_brake_btn.button_up.connect(func(): Input.action_release("brake"))
	_left_btn.button_down.connect(func(): Input.action_press("turn_left"))
	_left_btn.button_up.connect(func(): Input.action_release("turn_left"))
	_right_btn.button_down.connect(func(): Input.action_press("turn_right"))
	_right_btn.button_up.connect(func(): Input.action_release("turn_right"))

func update_timer(seconds: float) -> void:
	var clamped = max(0.0, seconds)
	var m = int(clamped) / 60
	var s = int(clamped) % 60
	timer_label.text = "%d:%02d" % [m, s]
	if clamped <= 10.0:
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
