extends Node

# Game progression tracking
var current_day: int = 1
var max_energy: int = 100
var current_energy: int = 100
var max_gas: int = 25
var current_gas: int = 15
var current_money: int = 0
var money_goal: int = 2500 # Daughter's Graduation Gift & Family Debt Goal
var fish_inventory: Array = []  # Array of species ids
var debug_start_with_talipapa_test_state: bool = true

#Day Tracking System
enum TIME_PERIOD {Morning, Afternoon, Night}
var current_time_index: int = 0

const TIME_SEQUENCE: Array[TIME_PERIOD] = [
	TIME_PERIOD.Morning,
	TIME_PERIOD.Afternoon,
	TIME_PERIOD.Night
]

func get_current_period() -> TIME_PERIOD:
	return TIME_SEQUENCE[current_time_index]
	
# Daily family living expenses (food, rice, utilities)
const DAILY_FAMILY_EXPENSE: int = 35

# Filipino Paon (Bait) System
var active_bait: String = "kawil" # "kawil", "hipon", "tahong"
var hipon_bait_count: int = 0
var tahong_bait_count: int = 0
const HIPON_BAIT_COST: int = 20 # Pack of 5
const TAHONG_BAIT_COST: int = 35 # Pack of 3

# Carinderia Daily Contracts (Aling Nena's Order)
var active_contract: Dictionary = {}

# Energy system
var fishing_energy_cost: int = 7

# Gas system
var gas_cost_to_opensea: int = 11
var gas_refuel_cost: int = 45  # Coins per refuel purchase
var gas_refuel_amount: int = 5  # Gas units per refuel

# Game length
var max_days: int = 7

# Result tracking (survives reset so end screens can display it)
var final_money: int = 0
var total_caught: int = 0

# Shop / upgrades
var has_bait: bool = false
var rod_level: int = 1
var boat_level: int = 1
const BAIT_COST: int = 30
const ROD_UPGRADE_COST: int = 400
const BOAT_UPGRADE_COST: int = 600
const MAX_ROD_LEVEL: int = 3
const MAX_BOAT_LEVEL: int = 3

# Weather system
const WEATHER_SUNNY: String = "Sunny"
const WEATHER_CLOUDY: String = "Cloudy"
const WEATHER_RAIN: String = "Rain"
const WEATHER_STORM: String = "Storm"
var weather: String = WEATHER_SUNNY
var weather_rolls: Array[String] = [
	WEATHER_CLOUDY, WEATHER_SUNNY, WEATHER_RAIN, WEATHER_SUNNY,
	WEATHER_CLOUDY, WEATHER_STORM, WEATHER_RAIN, WEATHER_SUNNY
]

# Filipino fish species
# Each species: name, min value, max value, rarity weight (higher = more common),
# and minigame difficulty tuning (bobber speed multiplier, target size, grace time)
const SPECIES: Array[Dictionary] = [
	{
		"id": "tilapia",
		"name": "Tilapia",
		"min_value": 40, "max_value": 70,
		"weight": 34,
		"speed": 1.0, "grace": 0.45,
		"emoji": "🐟",
	},
	{
		"id": "galunggong",
		"name": "Galunggong",
		"min_value": 70, "max_value": 110,
		"weight": 28,
		"speed": 1.15, "grace": 0.40,
		"emoji": "🐟",
	},
	{
		"id": "bangus",
		"name": "Bangus",
		"min_value": 90, "max_value": 140,
		"weight": 22,
		"speed": 1.3, "grace": 0.35,
		"emoji": "🐠",
	},
	{
		"id": "alimango",
		"name": "Alimango",
		"min_value": 200, "max_value": 350,
		"weight": 11,
		"speed": 1.55, "grace": 0.30,
		"emoji": "🦀",
	},
	{
		"id": "lapulapu",
		"name": "Lapu-Lapu",
		"min_value": 300, "max_value": 450,
		"weight": 5,
		"speed": 1.85, "grace": 0.25,
		"emoji": "🐡",
	},
]

# Weather affects both bite chance and the value of rarer catches
const WEATHER_BITE_MULTIPLIER: Dictionary = {
	WEATHER_SUNNY: 1.0,
	WEATHER_CLOUDY: 1.1,
	WEATHER_RAIN: 1.25,
	WEATHER_STORM: 1.5,
}

func _ready() -> void:
	# Initialize game state
	current_day = 1
	current_time_index = 0
	current_energy = max_energy
	current_gas = 13
	current_money = 0
	fish_inventory = ["tilapia", "tilapia", "bangus"]
	active_bait = "kawil"
	hipon_bait_count = 0
	tahong_bait_count = 0
	weather = roll_weather()
	generate_daily_contract()
	if debug_start_with_talipapa_test_state:
		current_gas = 100
		fish_inventory = ["tilapia", "galunggong", "bangus"]
		print("Talipapa test state enabled: 3 fish on hand")

func update_time() -> void:
	current_time_index += 1

	if current_time_index >= TIME_SEQUENCE.size():
		current_time_index = 0
		advance_day()

func advance_day() -> void:
	"""Move to next day. If max days reached, trigger end condition."""
	if current_day < max_days:
		current_time_index = 0
		current_day += 1
		weather = roll_weather()
		generate_daily_contract()
		print("Day %d started (weather: %s)" % [current_day, weather])
	else:
		# Game over - check win/lose condition
		check_game_end()

func generate_daily_contract() -> void:
	"""Generate a realistic daily Carinderia / Market order contract for the day."""
	match current_day:
		1, 2:
			active_contract = {
				"target_id": "tilapia",
				"target_name": "Tilapia",
				"count": 2,
				"reward": 150,
				"bonus": 40,
				"title": "Aling Nena's Carinderia: 2x Tilapia",
				"completed": false
			}
		3, 4:
			active_contract = {
				"target_id": "bangus",
				"target_name": "Bangus",
				"count": 2,
				"reward": 260,
				"bonus": 60,
				"title": "Fiesta Order: 2x Bangus",
				"completed": false
			}
		5, 6:
			active_contract = {
				"target_id": "alimango",
				"target_name": "Alimango",
				"count": 2,
				"reward": 450,
				"bonus": 90,
				"title": "Seafood Dampa Order: 2x Alimango",
				"completed": false
			}
		_:
			active_contract = {
				"target_id": "lapulapu",
				"target_name": "Lapu-Lapu",
				"count": 1,
				"reward": 500,
				"bonus": 120,
				"title": "Graduation Party Special: 1x Lapu-Lapu",
				"completed": false
			}

func claim_contract() -> bool:
	"""Fulfill active contract if required fish exist in inventory."""
	if active_contract.is_empty() or active_contract.get("completed", false):
		return false
	var target_id: String = active_contract.get("target_id", "")
	var req_count: int = active_contract.get("count", 1)

	var match_indices: Array[int] = []
	for i in range(fish_inventory.size()):
		if fish_inventory[i] == target_id:
			match_indices.append(i)
			if match_indices.size() >= req_count:
				break

	if match_indices.size() >= req_count:
		match_indices.reverse()
		for idx in match_indices:
			fish_inventory.remove_at(idx)

		var total_reward: int = active_contract.get("reward", 0) + active_contract.get("bonus", 0)
		add_money(total_reward)
		active_contract["completed"] = true
		print("Contract fulfilled! Earned P%d" % total_reward)
		return true
	return false

func get_contract_progress() -> Dictionary:
	if active_contract.is_empty():
		return {"in_bag": 0, "required": 0, "ready": false, "completed": false}
	var target_id: String = active_contract.get("target_id", "")
	var req_count: int = active_contract.get("count", 1)
	var in_bag: int = 0
	for f in fish_inventory:
		if f == target_id:
			in_bag += 1
	var is_completed: bool = active_contract.get("completed", false)
	return {
		"target_name": active_contract.get("target_name", ""),
		"in_bag": in_bag,
		"required": req_count,
		"ready": (in_bag >= req_count and not is_completed),
		"completed": is_completed
	}

func switch_bait(bait_type: String) -> bool:
	if bait_type == "kawil":
		active_bait = "kawil"
		return true
	elif bait_type == "hipon" and hipon_bait_count > 0:
		active_bait = "hipon"
		return true
	elif bait_type == "tahong" and tahong_bait_count > 0:
		active_bait = "tahong"
		return true
	return false

func sleep_until_morning() -> void:
	"""Sleep to next day, deduct daily family expense, and fully recover energy."""
	current_energy += 45
	update_time()

	# Deduct family daily expenses (rice, food, electricity)
	var expense := DAILY_FAMILY_EXPENSE
	if current_money >= expense:
		current_money -= expense
		print("Deducted P%d for family daily expenses" % expense)
	else:
		current_money = 0
		print("Money ran out paying family expenses!")

	advance_day()
	print("Slept - Day %d, Energy restored" % current_day)

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

func spend_energy(amount: int) -> bool:
	"""Attempt to spend energy. Returns true if successful."""
	if current_energy >= amount:
		current_energy -= amount
		return true
	return false

func get_energy_percent() -> float:
	"""Get energy as percentage (0.0 to 1.0)."""
	return float(current_energy) / float(max_energy)

func get_time_of_day() -> String:
	var current_time = TIME_SEQUENCE[current_time_index]
	return TIME_PERIOD.keys()[current_time]

func add_money(amount: int) -> void:
	"""Add money."""
	current_money += amount
	print("Money: ₱%d / ₱%d" % [current_money, money_goal])

func add_fish_to_inventory(species_id: String) -> void:
	"""Store caught fish until sold at the talipapa and consume active bait."""
	if get_species(species_id) == null:
		return
	fish_inventory.append(species_id)
	total_caught += 1
	consume_active_bait()

func consume_active_bait() -> void:
	"""Consume 1 count of special bait upon successful catch."""
	if active_bait == "hipon" and hipon_bait_count > 0:
		hipon_bait_count -= 1
		if hipon_bait_count <= 0:
			active_bait = "kawil"
	elif active_bait == "tahong" and tahong_bait_count > 0:
		tahong_bait_count -= 1
		if tahong_bait_count <= 0:
			active_bait = "kawil"

func has_fish_inventory() -> bool:
	return fish_inventory.size() > 0

const WEATHER_SELL_MULTIPLIER: Dictionary = {
	WEATHER_SUNNY: 1.0,
	WEATHER_CLOUDY: 1.1,
	WEATHER_RAIN: 1.25,
	WEATHER_STORM: 1.5,
}

func get_weather_sell_multiplier() -> float:
	if weather in WEATHER_SELL_MULTIPLIER:
		return WEATHER_SELL_MULTIPLIER[weather]
	return 1.0

func get_fish_inventory_value() -> int:
	var total: int = 0
	var mult := get_weather_sell_multiplier()
	for species_id in fish_inventory:
		var s = get_species(species_id)
		if s != null:
			var base_val := int(s.min_value)
			total += int(base_val * mult)
	return total

func get_fish_inventory_count() -> int:
	return fish_inventory.size()

func sell_all_fish() -> int:
	"""Sell all fish in inventory. Returns coins earned from the sale (includes weather bonus)."""
	if not has_fish_inventory():
		return 0

	var payout := 0
	var mult := get_weather_sell_multiplier()
	for species_id in fish_inventory:
		var s = get_species(species_id)
		if s != null:
			var base_val := randi_range(int(s.min_value), int(s.max_value))
			payout += int(base_val * mult)
	fish_inventory.clear()
	add_money(payout)
	return payout

func get_species(species_id: String) -> Dictionary:
	for s in SPECIES:
		if s.get("id", "") == species_id:
			return s
	return {}

func get_sea_zone(x_pos: float) -> String:
	if x_pos < 2000.0:
		return "Baybayin (Shallow)"
	elif x_pos < 4500.0:
		return "Gitnang Dagat (Mid)"
	else:
		return "Lalim ng Dagat (Deep)"

func roll_species_for_zone(x_pos: float) -> Dictionary:
	"""Pick a species weighted by depth zone and active Filipino bait."""
	var temp_species: Array[Dictionary] = []
	for s in SPECIES:
		var species_copy := s.duplicate(true)
		var w: float = species_copy["weight"]

		# Position weighting
		if x_pos < 2000.0:
			if s["id"] in ["tilapia", "galunggong"]:
				w *= 1.8
			elif s["id"] == "lapulapu":
				w *= 0.2
		elif x_pos < 4500.0:
			if s["id"] in ["bangus", "alimango"]:
				w *= 1.6
		else:
			if s["id"] in ["alimango", "lapulapu"]:
				w *= 2.5
			elif s["id"] == "tilapia":
				w *= 0.3

		# Active Paon (Bait) weighting
		if active_bait == "hipon":
			if s["id"] in ["galunggong", "bangus"]:
				w *= 1.8
		elif active_bait == "tahong":
			if s["id"] in ["alimango", "lapulapu"]:
				w *= 2.2

		species_copy["weight"] = max(1, int(w))
		temp_species.append(species_copy)

	var total_weight: int = 0
	for s in temp_species:
		total_weight += int(s["weight"])
	var roll := randi_range(1, max(1, total_weight))
	for s in temp_species:
		roll -= int(s["weight"])
		if roll <= 0:
			return get_species(s["id"])
	return SPECIES[0]

func roll_species() -> Dictionary:
	"""Pick a species weighted by default rarity (fallback)."""
	return roll_species_for_zone(1000.0)

# Paon Purchasing
func can_afford_paon_hipon() -> bool:
	return current_money >= HIPON_BAIT_COST

func buy_paon_hipon() -> bool:
	if can_afford_paon_hipon():
		current_money -= HIPON_BAIT_COST
		hipon_bait_count += 5
		active_bait = "hipon"
		return true
	return false

func can_afford_paon_tahong() -> bool:
	return current_money >= TAHONG_BAIT_COST

func buy_paon_tahong() -> bool:
	if can_afford_paon_tahong():
		current_money -= TAHONG_BAIT_COST
		tahong_bait_count += 3
		active_bait = "tahong"
		return true
	return false

func get_weather_bite_multiplier() -> float:
	if weather in WEATHER_BITE_MULTIPLIER:
		return WEATHER_BITE_MULTIPLIER[weather]
	return 1.0

# Shop helpers
func can_afford_bait() -> bool:
	return current_money >= BAIT_COST

func buy_bait() -> bool:
	if can_afford_bait():
		current_money -= BAIT_COST
		has_bait = true
		return true
	return false

func can_upgrade_rod() -> bool:
	return rod_level < MAX_ROD_LEVEL and current_money >= ROD_UPGRADE_COST

func upgrade_rod() -> bool:
	if can_upgrade_rod():
		current_money -= ROD_UPGRADE_COST
		rod_level += 1
		return true
	return false

func can_upgrade_boat() -> bool:
	return boat_level < MAX_BOAT_LEVEL and current_money >= BOAT_UPGRADE_COST

func upgrade_boat() -> bool:
	if can_upgrade_boat():
		current_money -= BOAT_UPGRADE_COST
		boat_level += 1
		max_gas += 15
		return true
	return false

func get_cast_power_multiplier() -> float:
	# Higher rod level = longer max cast distance
	return 1.0 + 0.35 * (rod_level - 1)

func check_game_end() -> void:
	"""Check win/lose conditions and trigger end state."""
	if current_day >= max_days:
		# Capture results BEFORE reset so end screens can display them
		final_money = current_money
		if current_money >= money_goal:
			print("=== VICTORY! You reached ₱%d! ===" % money_goal)
			reset_game()
			get_tree().change_scene_to_file("res://scenes/ui/victory.tscn")
		else:
			print("=== GAME OVER - You earned ₱%d / ₱%d ===" % [current_money, money_goal])
			reset_game()
			get_tree().change_scene_to_file("res://scenes/ui/defeat.tscn")

func reset_game() -> void:
	"""Reset to initial state for new game."""
	current_day = 1
	current_time_index = 0
	current_energy = max_energy
	current_gas = 13
	current_money = 0
	total_caught = 0
	fish_inventory = ["tilapia", "tilapia", "bangus"]
	has_bait = false
	active_bait = "kawil"
	hipon_bait_count = 0
	tahong_bait_count = 0
	rod_level = 1
	boat_level = 1
	max_gas = 25
	weather = roll_weather()
	active_contract = {}
	generate_daily_contract()

func roll_weather() -> String:
	randomize()
	return weather_rolls.pick_random()
