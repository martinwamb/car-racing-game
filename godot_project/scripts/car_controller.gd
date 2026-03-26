extends CharacterBody2D

# Top-down car physics

@export var max_speed: float = 300.0
@export var acceleration: float = 400.0
@export var friction: float = 500.0
@export var turn_speed: float = 180.0  # degrees per second

var _speed: float = 0.0
var _is_frozen: bool = false  # true during question popup

func _ready() -> void:
	_apply_upgrades()

func _physics_process(delta: float) -> void:
	if _is_frozen:
		return

	var input_dir = 0.0
	var turning = 0.0

	if Input.is_action_pressed("accelerate"):
		input_dir = 1.0
	elif Input.is_action_pressed("brake"):
		input_dir = -0.5

	if Input.is_action_pressed("turn_left"):
		turning = -1.0
	elif Input.is_action_pressed("turn_right"):
		turning = 1.0

	# Only turn when moving
	if abs(_speed) > 10.0:
		rotation_degrees += turning * turn_speed * delta * sign(_speed)

	# Accelerate / decelerate
	if input_dir != 0.0:
		_speed = move_toward(_speed, max_speed * input_dir, acceleration * delta)
	else:
		_speed = move_toward(_speed, 0.0, friction * delta)

	velocity = Vector2(0, -_speed).rotated(rotation)
	move_and_slide()

func freeze() -> void:
	_is_frozen = true
	_speed = move_toward(_speed, 0.0, friction)

func unfreeze() -> void:
	_is_frozen = false

func _apply_upgrades() -> void:
	if CoinSystem.owns("engine_1"):
		max_speed *= 1.25
	if CoinSystem.owns("tires_1"):
		turn_speed *= 1.2
