extends Node

# Game progression tracking
var current_day: int = 1
var current_time: float = 0.0  # 0-24 represents full day cycle
var max_energy: int = 100
var current_energy: int = 100
var max_gas: int = 100
var current_gas: int = 100
var current_money: int = 0
var money_goal: int = 10000

# Energy system
var fishing_energy_cost: int = 4

# Gas system
var gas_cost_to_opensea: int = 30
var gas_refuel_cost: int = 50  # Coins
var gas_refuel_amount: int = 50  # Gas units

# Time scaling - 1 real second = X in-game time units
# For 15-minute demo: complete 1 full day (24 hours) in 5 real minutes (300 seconds)
# So time_scale = 24 / 300 = 0.08 in-game hours per real second
var time_scale: float = 0.08  # Completes full day (24 hours) in 5 real minutes

# Demo constraints
var max_days: int = 3  # Only days 1-3 for demo
var demo_duration_minutes: float = 15.0

func _ready() -> void:
	# Initialize game state
	current_day = 1
	current_time = 6  # Start at 6 AM (morning)
	current_energy = max_energy
	current_gas = max_gas
	current_money = 0

func _process(delta: float) -> void:
	# Auto-update time each frame
	update_time(delta)

func update_time(delta: float) -> void:
	"""Advance in-game time. Full day cycle is 24 hours."""
	current_time += delta * time_scale 
	
	# Day complete - advance to next day or trigger end condition
	if current_time >= 24.0 and current_day > 3:
		set_process(false)
		check_game_end()
		
	elif current_time >= 24.0:
		current_time = 0.0
		advance_day()
		

func advance_day() -> void:
	"""Move to next day. If max days reached, trigger end condition."""
	if current_day < max_days:
		current_day += 1
		print("Day %d started" % current_day)
	else:
		# Game over - check win/lose condition
		check_game_end()

func spend_energy(amount: int) -> bool:
	"""Attempt to spend energy. Returns true if successful."""
	if current_energy >= amount:
		current_energy -= amount
		return true
	return false

func recover_energy(amount: int) -> void:
	"""Restore energy (up to max)."""
	current_energy = min(current_energy + amount, max_energy)

func sleep_until_morning() -> void:
	"""Sleep to next day and fully recover energy."""
	current_time = 6.0  # Wake up at 6 AM
	current_energy = max_energy
	current_gas = max_gas
	advance_day()
	print("Slept - Day %d, Energy and Gas restored" % current_day)

func spend_gas(amount: int) -> bool:
	"""Attempt to spend gas. Returns true if successful."""
	if current_gas >= amount:
		current_gas -= amount
		return true
	return false

func refuel_gas(amount: int) -> void:
	"""Restore gas (up to max)."""
	current_gas = min(current_gas + amount, max_gas)

func can_afford_refuel() -> bool:
	"""Check if player has enough money to refuel."""
	return current_money >= gas_refuel_cost

func buy_gas() -> bool:
	"""Attempt to refuel gas. Returns true if successful."""
	if can_afford_refuel():
		current_money -= gas_refuel_cost
		refuel_gas(gas_refuel_amount)
		return true
	return false

func can_travel_to_opensea() -> bool:
	"""Check if player has enough gas to travel to OpenSea."""
	return current_gas >= gas_cost_to_opensea

func travel_to_opensea() -> bool:
	"""Spend gas to travel to OpenSea. Returns true if successful."""
	if can_travel_to_opensea():
		current_gas -= gas_cost_to_opensea
		return true
	return false

func recover_gas(amount: int) -> void:
	"""Restore gas (up to max)."""
	current_gas = min(current_gas + amount, max_gas)

func can_drive_boat() -> bool:
	"""Check if boat can keep moving."""
	return current_gas > 0

func get_gas_percent() -> float:
	"""Get gas as percentage (0.0 to 1.0)."""
	if max_gas <= 0:
		return 0.0
	return float(current_gas) / float(max_gas)

func can_fish() -> bool:
	"""Check if player has enough energy to attempt fishing."""
	return current_energy >= fishing_energy_cost

func get_energy_percent() -> float:
	"""Get energy as percentage (0.0 to 1.0)."""
	return float(current_energy) / float(max_energy)

func get_time_of_day() -> String:
	"""Return formatted time string (6:00 AM - 11:59 PM)."""
	var hours = int(current_time) % 24
	var minutes = int((current_time - int(current_time)) * 60)
	var period = "AM" if hours < 12 else "PM"
	if hours == 0:
		hours = 12
	elif hours > 12:
		hours -= 12
	return "%02d:%02d %s" % [hours, minutes, period]

func add_money(amount: int) -> void:
	"""Add money and check for win condition."""
	current_money += amount
	print("Money: ₱%d / ₱%d" % [current_money, money_goal])
	if current_money >= money_goal:
		check_game_end()

func check_game_end() -> void:
	"""Check win/lose conditions and trigger end state."""
	if current_day >= max_days:
		if current_money >= money_goal:
			print("=== VICTORY! You reached ₱%d! ===" % money_goal)
			get_tree().change_scene_to_file("res://scenes/victory.tscn") 
		else:
			print("=== GAME OVER - You earned ₱%d / ₱%d ===" % [current_money, money_goal])
			get_tree().change_scene_to_file("res://scenes/defeat.tscn")

func reset_game() -> void:
	"""Reset to initial state for new game."""
	current_day = 1
	current_time = 6.0
	current_energy = max_energy
	current_gas = max_gas
	current_money = 0
	
