extends Control

@onready var age_panel: PanelContainer = $VBox/AgePanel
@onready var play_btn: Button = $VBox/PlayBtn
@onready var play2_btn: Button = $VBox/Play2Btn
@onready var play3_btn: Button = $VBox/Play3Btn
@onready var play4_btn: Button = $VBox/Play4Btn
@onready var coins_label: Label = $VBox/Coins
@onready var change_age_btn: Button = $VBox/ChangeAgeBtn
@onready var tips_panel: PanelContainer = $TipsPanel

const AGE_GROUPS = ["3-5", "6-8", "9-11", "12+"]

func _ready() -> void:
	coins_label.text = "🪙 %d coins" % AgeProfile.total_coins

	# If age already set, skip the picker and enable play
	if AgeProfile.age_group != "":
		age_panel.hide()
		_update_track_buttons()

	# Show tips only to brand new users (not returning users who updated)
	if AgeProfile.age_group == "" and not _is_tutorial_shown():
		tips_panel.show()

	# Wire age buttons
	var age_buttons = $VBox/AgePanel/AgeVBox/AgeButtons
	for i in range(age_buttons.get_child_count()):
		age_buttons.get_child(i).pressed.connect(_on_age_selected.bind(AGE_GROUPS[i]))

	# Wire main buttons
	play_btn.pressed.connect(_on_play)
	play2_btn.pressed.connect(_on_play2)
	play3_btn.pressed.connect(_on_play3)
	play4_btn.pressed.connect(_on_play4)
	$VBox/ShopBtn.pressed.connect(_on_shop)
	change_age_btn.pressed.connect(_show_age_panel)
	$TipsPanel/TipsVBox/GotItBtn.pressed.connect(_on_tips_close)

func _is_tutorial_shown() -> bool:
	var cfg = ConfigFile.new()
	if cfg.load("user://profile.cfg") != OK:
		return false
	return cfg.get_value("tutorial", "shown", false)

func _mark_tutorial_shown() -> void:
	var cfg = ConfigFile.new()
	cfg.load("user://profile.cfg")
	cfg.set_value("tutorial", "shown", true)
	cfg.save("user://profile.cfg")

func _on_tips_close() -> void:
	_mark_tutorial_shown()
	tips_panel.hide()

func _update_track_buttons() -> void:
	play_btn.disabled = false
	# Track 2, 3 and 4 require purchase
	play2_btn.disabled = not CoinSystem.owns("track_2")
	play3_btn.disabled = not CoinSystem.owns("track_3")
	play4_btn.disabled = not CoinSystem.owns("track_4")
	# Update labels to show lock state
	if not CoinSystem.owns("track_2"):
		play2_btn.text = "🔒  CITY CIRCUIT (200 coins)"
	else:
		play2_btn.text = "🌆  CITY CIRCUIT"
	if not CoinSystem.owns("track_3"):
		play3_btn.text = "🔒  DESERT CIRCUIT (350 coins)"
	else:
		play3_btn.text = "🏜️  DESERT CIRCUIT"
	if not CoinSystem.owns("track_4"):
		play4_btn.text = "🔒  ARCTIC CIRCUIT (500 coins)"
	else:
		play4_btn.text = "❄️  ARCTIC CIRCUIT"

func _on_age_selected(group: String) -> void:
	AgeProfile.set_age_group(group)
	age_panel.hide()
	_update_track_buttons()

func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/track_1.tscn")

func _on_play2() -> void:
	get_tree().change_scene_to_file("res://scenes/track_2.tscn")

func _on_play3() -> void:
	get_tree().change_scene_to_file("res://scenes/track_3.tscn")

func _on_play4() -> void:
	get_tree().change_scene_to_file("res://scenes/track_4.tscn")

func _on_shop() -> void:
	get_tree().change_scene_to_file("res://scenes/upgrade_shop.tscn")

func _show_age_panel() -> void:
	age_panel.show()
	play_btn.disabled = true
	play2_btn.disabled = true
	play3_btn.disabled = true
	play4_btn.disabled = true

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
