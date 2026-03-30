extends CanvasLayer

@onready var coins_label: Label = $TopBar/HBoxContainer/CoinsLabel
@onready var timer_label: Label = $TopBar/HBoxContainer/TimerLabel
@onready var lap_label: Label = $TopBar/HBoxContainer/LapLabel
@onready var coin_popup: Label = $CoinPopup
@onready var _accel_btn: Button = $TouchControls/AccelBtn
@onready var _brake_btn: Button = $TouchControls/BrakeBtn
@onready var _wheel: Panel = $TouchControls/SteeringWheel
@onready var _steer_label: Label = $TouchControls/SteeringWheel/SteerLabel

var _popup_tween: Tween

# Steering wheel state
var _wheel_touch_id: int = -1
var _wheel_start_x: float = 0.0

func _ready() -> void:
	coins_label.text = str(AgeProfile.total_coins)
	CoinSystem.coins_changed.connect(_on_coins_changed)

	# Wire accelerate / brake buttons
	_accel_btn.button_down.connect(func(): Input.action_press("accelerate"))
	_accel_btn.button_up.connect(func(): Input.action_release("accelerate"))
	_brake_btn.button_down.connect(func(): Input.action_press("brake"))
	_brake_btn.button_up.connect(func(): Input.action_release("brake"))

	# Wire steering wheel drag input
	_wheel.gui_input.connect(_on_wheel_input)

func _on_wheel_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_wheel_touch_id = event.index
			_wheel_start_x = event.position.x
		elif event.index == _wheel_touch_id:
			_release_steer()
	elif event is InputEventScreenDrag:
		if event.index == _wheel_touch_id:
			_apply_steer(event.position.x - _wheel_start_x)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_wheel_touch_id = 0
				_wheel_start_x = event.position.x
			else:
				_release_steer()
	elif event is InputEventMouseMotion and _wheel_touch_id == 0:
		_apply_steer(event.position.x - _wheel_start_x)

func _apply_steer(delta_x: float) -> void:
	if delta_x < -20:
		Input.action_press("turn_left")
		Input.action_release("turn_right")
		_steer_label.text = "◄◄  STEERING"
	elif delta_x > 20:
		Input.action_press("turn_right")
		Input.action_release("turn_left")
		_steer_label.text = "STEERING  ►►"
	else:
		Input.action_release("turn_left")
		Input.action_release("turn_right")
		_steer_label.text = "◄  STEER  ►"

func _release_steer() -> void:
	_wheel_touch_id = -1
	Input.action_release("turn_left")
	Input.action_release("turn_right")
	_steer_label.text = "◄  STEER  ►"

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
