extends CanvasLayer

var shop_open := false
var message_timer := 0.0

@onready var panel = get_node_or_null("Panel")
@onready var stock_label: Label = get_node_or_null("Panel/StockLabel") as Label
@onready var money_label: Label = get_node_or_null("Panel/MoneyLabel") as Label
@onready var message_label: Label = get_node_or_null("Panel/MessageLabel") as Label
@onready var buy_fuel_button: Button = get_node_or_null("Panel/BuyFuel") as Button
@onready var buy_bait_button: Button = get_node_or_null("Panel/BuyBait") as Button
@onready var upgrade_rod_button: Button = get_node_or_null("Panel/UpgradeRod") as Button
@onready var upgrade_boat_button: Button = get_node_or_null("Panel/UpgradeBoat") as Button

func _ready() -> void:
	add_to_group("shop_open")
	if panel:
		panel.visible = false

func _process(delta: float) -> void:
	if not shop_open:
		return
	if Input.is_action_just_pressed("ESC"):
		close_shop()
		return
	update_labels()

func _unhandled_input(event: InputEvent) -> void:
	if shop_open and event.is_action_pressed("sell"):
		_on_sell_all_pressed()
	elif shop_open and event.is_action_pressed("refuel"):
		_on_buy_fuel_pressed()

func open_shop() -> void:
	shop_open = true
	if panel:
		panel.visible = true
	get_tree().paused = true
	update_labels()

func close_shop() -> void:
	shop_open = false
	if panel:
		panel.visible = false
	get_tree().paused = false

func is_open() -> bool:
	return shop_open

func update_labels() -> void:
	if stock_label:
		stock_label.text = "Stock: %d fish (worth P%d)" % [GameState.get_fish_inventory_count(), GameState.get_fish_inventory_value()]
	
	# Graduation Goal Narrative Label
	if money_label:
		money_label.text = "Money: P%d / P%d (Goal: Daughter's Graduation Gift 🎓)" % [GameState.current_money, GameState.money_goal]

	if buy_fuel_button:
		buy_fuel_button.text = "Buy Fuel (R): P%d for +%d gas [%d/%d]" % [GameState.gas_refuel_cost, GameState.gas_refuel_amount, GameState.current_gas, GameState.max_gas]
		buy_fuel_button.disabled = GameState.current_gas >= GameState.max_gas or not GameState.can_afford_refuel()

	# Display Paon (Filipino Bait) Stock
	if buy_bait_button:
		buy_bait_button.text = "Buy Paon Hipon (P%d for 5x): Active: %s (Hipon: %d, Tahong: %d)" % [
			GameState.HIPON_BAIT_COST, 
			GameState.active_bait.capitalize(), 
			GameState.hipon_bait_count, 
			GameState.tahong_bait_count
		]
		buy_bait_button.disabled = not GameState.can_afford_paon_hipon()

	if upgrade_rod_button:
		upgrade_rod_button.text = "Upgrade Rod: P%d (Longer Cast) [Lv %d/%d]" % [GameState.ROD_UPGRADE_COST, GameState.rod_level, GameState.MAX_ROD_LEVEL]
		upgrade_rod_button.disabled = not GameState.can_upgrade_rod()

	if upgrade_boat_button:
		upgrade_boat_button.text = "Upgrade Boat: P%d (+Speed & +15 Gas) [Lv %d/%d]" % [GameState.BOAT_UPGRADE_COST, GameState.boat_level, GameState.MAX_BOAT_LEVEL]
		upgrade_boat_button.disabled = not GameState.can_upgrade_boat()

func _show_message(text: String) -> void:
	if message_label:
		message_label.text = text
		message_timer = 2.0

func _on_sell_all_pressed() -> void:
	var payout := GameState.sell_all_fish()
	if payout > 0:
		SoundManager.play_sfx("select")
		_show_message("Sold fish for P%d!" % payout)
	else:
		# Check if player can fulfill active contract instead
		if GameState.claim_contract():
			SoundManager.play_sfx("select")
			_show_message("Fulfilled Carinderia Order Contract!")
		else:
			_show_message("No fish in stock!")
	update_labels()

func _on_buy_fuel_pressed() -> void:
	if GameState.buy_gas():
		SoundManager.play_sfx("select")
		_show_message("Refueled +%d gas!" % GameState.gas_refuel_amount)
	else:
		_show_message("Not enough money or tank is full!")
	update_labels()

func _on_buy_bait_pressed() -> void:
	if GameState.buy_paon_hipon():
		SoundManager.play_sfx("select")
		_show_message("Bought 5x Paong Hipon! (Attracts Bangus/Galunggong)")
	else:
		_show_message("Not enough money for Paong Hipon (P20)!")
	update_labels()

func _on_upgrade_rod_pressed() -> void:
	if GameState.upgrade_rod():
		SoundManager.play_sfx("select")
		_show_message("Rod upgraded to Lv %d!" % GameState.rod_level)
	else:
		_show_message("Can't upgrade rod!")
	update_labels()

func _on_upgrade_boat_pressed() -> void:
	if GameState.upgrade_boat():
		SoundManager.play_sfx("select")
		_show_message("Boat upgraded to Lv %d! Speed increased!" % GameState.boat_level)
	else:
		_show_message("Can't upgrade boat!")
	update_labels()

func _on_close_pressed() -> void:
	close_shop()
