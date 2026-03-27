extends Control

@onready var title_label: Label = $TitleContainer/Title
@onready var subtitle_label: Label = $TitleContainer/Subtitle
@onready var car_red: TextureRect = $Cars/CarRed
@onready var car_blue: TextureRect = $Cars/CarBlue
@onready var car_yellow: TextureRect = $Cars/CarYellow
@onready var fade_rect: ColorRect = $FadeRect

var _done := false

func _ready() -> void:
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	fade_rect.color.a = 1.0

	# Cars start off-screen to the left at different positions
	car_yellow.position.x = -280.0
	car_red.position.x    = -380.0
	car_blue.position.x   = -480.0

	# Fade in from black, then kick off the sequence
	var fade_in := create_tween()
	fade_in.tween_property(fade_rect, "color:a", 0.0, 0.5)
	fade_in.tween_callback(_start_sequence)

func _start_sequence() -> void:
	# Cars race across at different speeds and lanes
	var t_yellow := create_tween()
	t_yellow.tween_property(car_yellow, "position:x", 1400.0, 1.1) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	var t_red := create_tween()
	t_red.tween_interval(0.12)
	t_red.tween_property(car_red, "position:x", 1400.0, 1.4) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	var t_blue := create_tween()
	t_blue.tween_interval(0.25)
	t_blue.tween_property(car_blue, "position:x", 1400.0, 1.7) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	# Title fades in as the cars are crossing
	var t_title := create_tween()
	t_title.tween_interval(0.4)
	t_title.tween_property(title_label, "modulate:a", 1.0, 0.6)
	t_title.tween_interval(0.25)
	t_title.tween_property(subtitle_label, "modulate:a", 1.0, 0.4)

	# Master timer: hold → fade to black → switch scene
	var t_main := create_tween()
	t_main.tween_interval(3.4)
	t_main.tween_property(fade_rect, "color:a", 1.0, 0.5)
	t_main.tween_callback(_go_to_menu)

func _go_to_menu() -> void:
	if _done:
		return
	_done = true
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _input(event: InputEvent) -> void:
	# Any key or click skips the intro
	if event is InputEventKey or event is InputEventMouseButton:
		if event.is_pressed():
			_go_to_menu()
