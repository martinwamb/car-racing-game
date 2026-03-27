extends Control

@onready var age_panel: PanelContainer = $VBox/AgePanel
@onready var play_btn: Button = $VBox/PlayBtn
@onready var play2_btn: Button = $VBox/Play2Btn
@onready var coins_label: Label = $VBox/Coins
@onready var change_age_btn: Button = $VBox/ChangeAgeBtn

const AGE_GROUPS = ["3-5", "6-8", "9-11", "12+"]

func _ready() -> void:
	coins_label.text = "🪙 %d coins" % AgeProfile.total_coins

	# If age already set, skip the picker and enable play
	if AgeProfile.age_group != "":
		age_panel.hide()
		play_btn.disabled = false
		play2_btn.disabled = false

	# Wire age buttons
	var age_buttons = $VBox/AgePanel/AgeVBox/AgeButtons
	for i in range(age_buttons.get_child_count()):
		age_buttons.get_child(i).pressed.connect(_on_age_selected.bind(AGE_GROUPS[i]))

	# Wire main buttons
	play_btn.pressed.connect(_on_play)
	play2_btn.pressed.connect(_on_play2)
	$VBox/ShopBtn.pressed.connect(_on_shop)
	change_age_btn.pressed.connect(_show_age_panel)

func _on_age_selected(group: String) -> void:
	AgeProfile.set_age_group(group)
	age_panel.hide()
	play_btn.disabled = false
	play2_btn.disabled = false

func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/track_1.tscn")

func _on_play2() -> void:
	get_tree().change_scene_to_file("res://scenes/track_2.tscn")

func _on_shop() -> void:
	get_tree().change_scene_to_file("res://scenes/upgrade_shop.tscn")

func _show_age_panel() -> void:
	age_panel.show()
	play_btn.disabled = true
	play2_btn.disabled = true
