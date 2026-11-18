extends GridContainer

signal puzzle_solved
signal cogs_remaining_changed(remaining: int)

const GRID_SIZE := 5
const CELL_SIZE := Vector2(64, 64)
const DIRECTIONS: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT
]

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

		var cell := Vector2i(i % GRID_SIZE, i / GRID_SIZE)
		slot.gui_input.connect(_on_slot_gui_input.bind(cell, slot))

	setup_sample_level()
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

	print("Puzzle Solved!")
	puzzle_solved.emit()

func setup_sample_level() -> void:
	# Start at (0,0) [CW], Obstacle at (2,0), Target at (4,0) [CW]
	spawn_cog(Vector2i(0, 0), slots[0], CogUI.Type.START, true)
	spawn_cog(Vector2i(2, 0), slots[2], CogUI.Type.BLOCKED, true)
	spawn_cog(Vector2i(4, 0), slots[4], CogUI.Type.TARGET, true, 1)
	spawn_cog(Vector2i(2, 1), slots[7], CogUI.Type.BLOCKED, true)
