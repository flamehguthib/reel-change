extends GridContainer

signal puzzle_solved
signal cogs_remaining_changed(remaining: int)

const GRID_SIZE := 5
const CELL_SIZE := Vector2(128, 128)
const DIRECTIONS: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]

var slot_bgs: Array[Panel] = []

const COLOR_START_BG = Color(0.08, 0.45, 0.42, 0.35)
const COLOR_START_BORDER = Color(0.2, 0.95, 0.85, 0.85)

const COLOR_TARGET_BG = Color(0.45, 0.32, 0.05, 0.35)
const COLOR_TARGET_BORDER = Color(1.0, 0.75, 0.15, 0.85)

const COLOR_BLOCKED_BG = Color(0.35, 0.1, 0.1, 0.4)
const COLOR_BLOCKED_BORDER = Color(0.8, 0.2, 0.2, 0.6)

const COLOR_NORMAL_BG = Color(0.0, 0.0, 0.0, 0.15)
const COLOR_NORMAL_BORDER = Color(1.0, 1.0, 1.0, 0.08)

const COLOR_SPIN_RIGHT_BG = Color(0.1, 0.5, 0.18, 0.42)
const COLOR_SPIN_RIGHT_BORDER = Color(0.25, 0.95, 0.4, 0.9)

@export var cog_texture: Texture2D # Assign your cog spritesheet here in the Inspector
@export var max_player_cogs: int = 10

var slots: Array[Control] = []
var cogs: Dictionary = {} # Maps Vector2i -> CogUI
var placed_player_cogs: int = 0

func _ready() -> void:
	columns = GRID_SIZE
	add_theme_constant_override("h_separation", 0)
	add_theme_constant_override("v_separation", 0)

	for i in range(GRID_SIZE * GRID_SIZE):
		var slot := Control.new()
		slot.custom_minimum_size = CELL_SIZE
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		add_child(slot)
		slots.append(slot)
		
		var bg := Panel.new()
		bg.custom_minimum_size = CELL_SIZE
		bg.size = CELL_SIZE
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(bg)
		slot_bgs.append(bg)

		var cell := Vector2i(i % GRID_SIZE, i / GRID_SIZE)
		slot.gui_input.connect(_on_slot_gui_input.bind(cell, slot))

	random_level()
	recalculate_grid()

func _on_slot_gui_input(event: InputEvent, cell: Vector2i, slot: Control) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if cogs.has(cell):
			var existing: CogUI = cogs[cell]
			if existing.is_locked:
				return
			cogs.erase(cell)
			existing.queue_free()
			placed_player_cogs -= 1
			cogs_remaining_changed.emit(max_player_cogs - placed_player_cogs)
			recalculate_grid()
		elif placed_player_cogs < max_player_cogs:
			spawn_cog(cell, slot, CogUI.Type.NORMAL, false)
			placed_player_cogs += 1
			cogs_remaining_changed.emit(max_player_cogs - placed_player_cogs)
			recalculate_grid()

func spawn_cog(cell: Vector2i, slot: Control, type: CogUI.Type, locked: bool, req_dir: int = 1) -> void:
	var cog := CogUI.new()
	slot.add_child(cog)
	cog.setup(cell, CELL_SIZE, cog_texture, type, locked, req_dir)
	cogs[cell] = cog

func recalculate_grid() -> void:
	var queue: Array[Vector2i] = []
	var visited: Dictionary = {}
	var targets: Array[CogUI] = []

	# 1. Reset all non-start cogs and queue the Start cog
	for cell: Vector2i in cogs:
		var cog: CogUI = cogs[cell]
		if cog.piece_type == CogUI.Type.START:
			cog.spin_dir = 1 # Clockwise
			visited[cell] = true
			queue.append(cell)
		else:
			cog.spin_dir = 0
			if cog.piece_type == CogUI.Type.TARGET:
				targets.append(cog)

	# 2. Propagate alternating spin direction to adjacent rows and columns
	while queue.size() > 0:
		var current_cell: Vector2i = queue.pop_front()
		var current_cog: CogUI = cogs[current_cell]

		for dir in DIRECTIONS:
			var next_cell: Vector2i = current_cell + dir
			if not cogs.has(next_cell) or visited.has(next_cell):
				continue

			var neighbor: CogUI = cogs[next_cell]
			if neighbor.piece_type == CogUI.Type.BLOCKED:
				continue

			neighbor.spin_dir = -current_cog.spin_dir
			visited[next_cell] = true
			queue.append(next_cell)

	# 3. Check if all target cogs match their required spin direction
	if targets.is_empty():
		return
	for target in targets:
		if target.spin_dir != target.required_dir:
			return
	update_tile_color()
	print("Puzzle Solved!")
	puzzle_solved.emit()

func random_level() -> void:
	var level = randi_range(1, 5)
	if level == 1: 
		set_slot_style(slot_bgs[0], COLOR_START_BG, COLOR_START_BORDER, 1)
		set_slot_style(slot_bgs[4], COLOR_TARGET_BG, COLOR_TARGET_BORDER, 1)
		set_slot_style(slot_bgs[2], COLOR_BLOCKED_BG, COLOR_BLOCKED_BORDER, 1)
		set_slot_style(slot_bgs[7], COLOR_BLOCKED_BG, COLOR_BLOCKED_BORDER, 1)
		spawn_cog(Vector2i(0, 0), slots[0], CogUI.Type.START, true)
		spawn_cog(Vector2i(2, 0), slots[2], CogUI.Type.BLOCKED, true)
		spawn_cog(Vector2i(4, 0), slots[4], CogUI.Type.TARGET, true, 1)
		spawn_cog(Vector2i(2, 1), slots[7], CogUI.Type.BLOCKED, true)
	elif level == 2: 
		set_slot_style(slot_bgs[20], COLOR_START_BG, COLOR_START_BORDER, 1)
		set_slot_style(slot_bgs[4], COLOR_TARGET_BG, COLOR_TARGET_BORDER, 1)
		set_slot_style(slot_bgs[12], COLOR_BLOCKED_BG, COLOR_BLOCKED_BORDER, 1)
		set_slot_style(slot_bgs[17], COLOR_BLOCKED_BG, COLOR_BLOCKED_BORDER, 1)
		spawn_cog(Vector2i(0, 4), slots[20], CogUI.Type.START, true)
		spawn_cog(Vector2i(4, 0), slots[4], CogUI.Type.TARGET, true, 1)
		spawn_cog(Vector2i(2, 2), slots[12], CogUI.Type.BLOCKED, true, 1)
		spawn_cog(Vector2i(2, 3), slots[17], CogUI.Type.BLOCKED, true)
	elif level == 3:
		set_slot_style(slot_bgs[10], COLOR_START_BG, COLOR_START_BORDER, 1)
		set_slot_style(slot_bgs[14], COLOR_TARGET_BG, COLOR_TARGET_BORDER, 1)
		set_slot_style(slot_bgs[12], COLOR_BLOCKED_BG, COLOR_BLOCKED_BORDER, 1)
		spawn_cog(Vector2i(0, 2), slots[10], CogUI.Type.START, true)
		spawn_cog(Vector2i(2, 2), slots[12], CogUI.Type.BLOCKED, true)
		spawn_cog(Vector2i(4, 2), slots[14], CogUI.Type.TARGET, true, 1)
	elif level == 4:
		set_slot_style(slot_bgs[0], COLOR_START_BG, COLOR_START_BORDER, 1)
		set_slot_style(slot_bgs[9], COLOR_TARGET_BG, COLOR_TARGET_BORDER, 1)
		set_slot_style(slot_bgs[6], COLOR_BLOCKED_BG, COLOR_BLOCKED_BORDER, 1)
		set_slot_style(slot_bgs[13], COLOR_BLOCKED_BG, COLOR_BLOCKED_BORDER, 1)
		set_slot_style(slot_bgs[18], COLOR_BLOCKED_BG, COLOR_BLOCKED_BORDER, 1)
		set_slot_style(slot_bgs[23], COLOR_BLOCKED_BG, COLOR_BLOCKED_BORDER, 1)
		set_slot_style(slot_bgs[1], COLOR_BLOCKED_BG, COLOR_BLOCKED_BORDER, 1)
		spawn_cog(Vector2i(0, 0), slots[0], CogUI.Type.START, true)
		spawn_cog(Vector2i(1, 0), slots[1], CogUI.Type.BLOCKED, true)
		spawn_cog(Vector2i(1, 1), slots[6], CogUI.Type.BLOCKED, true)
		spawn_cog(Vector2i(3, 2), slots[13], CogUI.Type.BLOCKED, true)
		spawn_cog(Vector2i(3, 3), slots[18], CogUI.Type.BLOCKED, true)
		spawn_cog(Vector2i(3, 4), slots[23], CogUI.Type.BLOCKED, true)
		spawn_cog(Vector2i(4, 1), slots[9], CogUI.Type.TARGET, true, -1)
	elif level == 5:
		set_slot_style(slot_bgs[22], COLOR_START_BG, COLOR_START_BORDER, 1)
		set_slot_style(slot_bgs[9], COLOR_TARGET_BG, COLOR_TARGET_BORDER, 1)
		set_slot_style(slot_bgs[5], COLOR_TARGET_BG, COLOR_TARGET_BORDER, 1)
		set_slot_style(slot_bgs[21], COLOR_BLOCKED_BG, COLOR_BLOCKED_BORDER, 1)
		set_slot_style(slot_bgs[23], COLOR_BLOCKED_BG, COLOR_BLOCKED_BORDER, 1)
		set_slot_style(slot_bgs[12], COLOR_BLOCKED_BG, COLOR_BLOCKED_BORDER, 1)
		spawn_cog(Vector2i(2, 4), slots[22], CogUI.Type.START, true)
		spawn_cog(Vector2i(1, 4), slots[21], CogUI.Type.BLOCKED, true)
		spawn_cog(Vector2i(3, 4), slots[23], CogUI.Type.BLOCKED, true)
		spawn_cog(Vector2i(2, 2), slots[12], CogUI.Type.BLOCKED, true)
		spawn_cog(Vector2i(0, 1), slots[5], CogUI.Type.TARGET, true, -1)
		spawn_cog(Vector2i(4, 1), slots[9], CogUI.Type.TARGET, true, -1)

func set_slot_style(panel: Panel, bg_color: Color, border_color: Color, border_width: int) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.border_blend = false
	panel.add_theme_stylebox_override("panel", style)

func update_tile_color() -> void:
	# 1. Reset all tiles to default first
	for bg: Panel in slot_bgs:
		set_slot_style(bg, COLOR_NORMAL_BG, COLOR_NORMAL_BORDER, 1)

	# 2. Color tiles directly underneath each existing cog
	for cog: CogUI in cogs.values():
		var idx: int = slots.find(cog.get_parent() as Control)
		if idx == -1:
			continue
		var bg: Panel = slot_bgs[idx]

		# Flip == -1 to == 1 if your CogUI sprite rotates right on +1
		if cog.spin_dir == cog.required_dir and cog.piece_type == CogUI.Type.TARGET:
			set_slot_style(bg, COLOR_SPIN_RIGHT_BG, COLOR_SPIN_RIGHT_BORDER, 3)
			continue

		match cog.piece_type:
			CogUI.Type.START:
				set_slot_style(bg, COLOR_START_BG, COLOR_START_BORDER, 3)
			CogUI.Type.TARGET:
				set_slot_style(bg, COLOR_TARGET_BG, COLOR_TARGET_BORDER, 3)
			CogUI.Type.BLOCKED:
				set_slot_style(bg, COLOR_BLOCKED_BG, COLOR_BLOCKED_BORDER, 2)
