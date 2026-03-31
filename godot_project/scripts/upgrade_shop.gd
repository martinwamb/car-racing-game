extends Control

@onready var coins_label: Label = $VBox/CoinsLabel
@onready var item_list: VBoxContainer = $VBox/ItemList

func _ready() -> void:
	_refresh_coins()
	_build_item_list()
	$VBox/BackBtn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))

func _refresh_coins() -> void:
	coins_label.text = "🪙 %d coins available" % AgeProfile.total_coins

func _build_item_list() -> void:
	# Clear old items
	for child in item_list.get_children():
		child.queue_free()

	for upgrade_id in CoinSystem.UPGRADES:
		var data = CoinSystem.UPGRADES[upgrade_id]
		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var info = Label.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var owned = CoinSystem.owns(upgrade_id)
		info.text = "%s — %s\n%s" % [
			data["name"],
			("OWNED" if owned else "🪙 %d coins" % data["cost"]),
			data["description"]
		]
		row.add_child(info)

		var btn = Button.new()
		btn.custom_minimum_size = Vector2(100, 40)
		btn.text = "Buy" if not owned else "✓"
		btn.disabled = owned or AgeProfile.total_coins < data["cost"]
		btn.pressed.connect(_on_buy.bind(upgrade_id))
		row.add_child(btn)

		var sep = HSeparator.new()
		item_list.add_child(row)
		item_list.add_child(sep)

func _on_buy(upgrade_id: String) -> void:
	if CoinSystem.purchase(upgrade_id):
		_refresh_coins()
		_build_item_list()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
